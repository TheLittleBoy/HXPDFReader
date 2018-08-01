//
//  HXPDFReaderThumbsView.m
//  HXPDFReader
//
//  Created by Mac on 2018/8/1.
//  Copyright © 2018年 华夏大地教育网. All rights reserved.
//

#import "HXPDFReaderThumbsView.h"

@interface HXPDFReaderThumbsView () <UIScrollViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation HXPDFReaderThumbsView
{
	CGPoint lastContentOffset;

	HXPDFReaderThumbView *touchedCell;

	NSMutableArray *thumbCellsQueue;

	NSMutableArray *thumbCellsVisible;

	NSInteger _thumbsX, _thumbsY, _thumbX;

	CGSize _thumbSize, _lastViewSize;

	NSUInteger _thumbCount;

	BOOL canUpdate;
}

#pragma mark - Properties

@synthesize delegate;

#pragma mark - HXPDFReaderThumbsView instance methods

- (instancetype)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{
		self.scrollsToTop = NO;
		self.autoresizesSubviews = NO;
		self.delaysContentTouches = NO;
		self.alwaysBounceVertical = YES;
		self.contentMode = UIViewContentModeRedraw;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];

		[super setDelegate:self]; // Set the superclass UIScrollView delegate

		thumbCellsQueue = [NSMutableArray new];
        thumbCellsVisible = [NSMutableArray new]; // Cell management arrays

		UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
		//tapGesture.numberOfTouchesRequired = 1; tapGesture.numberOfTapsRequired = 1; tapGesture.delegate = self;
		[self addGestureRecognizer:tapGesture]; 

		UILongPressGestureRecognizer *pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePressGesture:)];
		pressGesture.minimumPressDuration = 0.8; //pressGesture.numberOfTouchesRequired = 1; pressGesture.delegate = self;
		[self addGestureRecognizer:pressGesture]; 

		lastContentOffset = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
	}

	return self;
}

- (void)requeueThumbCell:(HXPDFReaderThumbView *)tvCell
{
	[thumbCellsQueue addObject:tvCell];

	[thumbCellsVisible removeObject:tvCell];

	tvCell.tag = NSIntegerMin; tvCell.hidden = YES;

	[tvCell reuse]; // Reuse the cell
}

- (void)requeueAllThumbCells
{
	if (thumbCellsVisible.count > 0)
	{
		NSArray *visible = [thumbCellsVisible copy];

		for (HXPDFReaderThumbView *tvCell in visible)
		{
			[self requeueThumbCell:tvCell];
		}
	}
}

- (HXPDFReaderThumbView *)dequeueThumbCellWithFrame:(CGRect)frame
{
	HXPDFReaderThumbView *theCell = nil;

	if (thumbCellsQueue.count > 0) // Reuse existing cell
	{
		theCell = [thumbCellsQueue objectAtIndex:0];

		[thumbCellsQueue removeObjectAtIndex:0]; // Dequeue it

		theCell.frame = frame; // Position the reused cell
	}
	else // Allocate a brand new thumb cell subclass for our use
	{
		theCell = [delegate thumbsView:self thumbCellWithFrame:frame];

		//assert([theCell isKindOfClass:[ReaderThumbView class]]);

		theCell.tag = NSIntegerMin; theCell.hidden = YES;

		[self insertSubview:theCell atIndex:0]; // Add
	}

	[thumbCellsVisible addObject:theCell]; 

	return theCell;
}

- (NSMutableIndexSet *)visibleIndexSetForContentOffset
{
	CGFloat minY = self.contentOffset.y; // Content offset
	CGFloat maxY = (minY + self.bounds.size.height - 1.0f);

	NSInteger startRow = (minY / _thumbSize.height); // Start row
	NSInteger finalRow = (maxY / _thumbSize.height); // Final row

	NSInteger startIndex = (startRow * _thumbsX); // Start index
	NSInteger finalIndex = (finalRow * _thumbsX); // Final index

	finalIndex += (_thumbsX - 1); // Last index value in last row

	NSInteger maximumIndex = (_thumbCount - 1); // Maximum index value

    if (finalIndex > maximumIndex) {
        finalIndex = maximumIndex; // Limit it
    }

	NSRange indexRange = NSMakeRange(startIndex, (finalIndex - startIndex + 1));

	return [NSMutableIndexSet indexSetWithIndexesInRange:indexRange];
}

- (HXPDFReaderThumbView *)thumbCellContainingPoint:(CGPoint)point
{
	HXPDFReaderThumbView *theCell = nil;

	for (HXPDFReaderThumbView *tvCell in thumbCellsVisible)
	{
		if (CGRectContainsPoint(tvCell.frame, point) == true)
		{
			theCell = tvCell; break; // Found it
		}
	}

	return theCell;
}

- (CGRect)thumbCellFrameForIndex:(NSInteger)index
{
	CGRect thumbRect; thumbRect.size = _thumbSize;

	NSInteger thumbY = ((index / _thumbsX) * _thumbSize.height); // X, Y

	NSInteger thumbX = (((index % _thumbsX) * _thumbSize.width) + _thumbX);

	thumbRect.origin.x = thumbX; thumbRect.origin.y = thumbY;

	return thumbRect;
}

- (void)updateContentSize:(NSUInteger)thumbCount
{
	canUpdate = NO; // Disable updates

	if (thumbCount > 0) // Have some thumbs
	{
		CGFloat bw = self.bounds.size.width;

		_thumbsX = (bw / _thumbSize.width);

		if (_thumbsX < 1) _thumbsX = 1;

		_thumbsY = (thumbCount / _thumbsX);

        if ((_thumbsX * _thumbsY) < thumbCount) {
            _thumbsY++;
        }

		CGFloat tw = (_thumbsX * _thumbSize.width);
		CGFloat th = (_thumbsY * _thumbSize.height);

        if (tw < bw) {
			_thumbX = ((bw - tw) * 0.5f);
        } else {
			_thumbX = 0; // Reset
        }

        if (tw < bw) {
            tw = bw; // Limit
        }

		[self setContentSize:CGSizeMake(tw, th)];
	}
	else // Zero (0) thumbs
	{
		[self setContentSize:CGSizeZero];
	}

	canUpdate = YES; // Enable updates
}

- (void)layoutSubviews
{
	if (CGSizeEqualToSize(_lastViewSize, CGSizeZero) == true)
	{
		_lastViewSize = self.bounds.size; // Initial view size
	}
	else
	if (CGSizeEqualToSize(_lastViewSize, self.bounds.size) == false)
	{
		_lastViewSize = self.bounds.size; // Track the view size

		[self updateContentSize:_thumbCount]; // Update the content size

		NSMutableArray *requeueCells = [NSMutableArray array]; // Requeue cell list

		NSMutableIndexSet *visibleIndexSet = [self visibleIndexSetForContentOffset];

		for (HXPDFReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
		{
			NSInteger index = tvCell.tag; // Get the cell's index value

			if ([visibleIndexSet containsIndex:index] == YES) // Visible cell
			{
				tvCell.frame = [self thumbCellFrameForIndex:index]; // Frame

				[visibleIndexSet removeIndex:index]; // Remove from set
			}
			else // Add it to the list of cells to requeue
			{
				[requeueCells addObject:tvCell];
			}
		}

		for (HXPDFReaderThumbView *tvCell in requeueCells) // Enumerate requeue cells
		{
			[self requeueThumbCell:tvCell]; // Requeue the thumb cell
		}

		[visibleIndexSet enumerateIndexesUsingBlock: // Enumerate visible indexes
			^(NSUInteger index, BOOL *stop)
			{
				CGRect thumbRect = [self thumbCellFrameForIndex:index]; // Frame

				HXPDFReaderThumbView *tvCell = [self dequeueThumbCellWithFrame:thumbRect];

                [self->delegate thumbsView:self updateThumbCell:tvCell forIndex:index];

				tvCell.tag = index; tvCell.hidden = NO; // Tag and show it
			}
		];
	}
}

- (void)setThumbSize:(CGSize)thumbSize
{
	if (CGSizeEqualToSize(_thumbSize, CGSizeZero) == true)
	{
		if (CGSizeEqualToSize(thumbSize, CGSizeZero) == false)
		{
			_thumbSize = thumbSize; // Set the maximum thumb size
		}
	}
}

- (void)reloadThumbsCenterOnIndex:(NSInteger)index
{
	assert(delegate != nil); // Check delegate

	assert(CGSizeEqualToSize(_thumbSize, CGSizeZero) == false);

	if (self.decelerating == YES) // Stop scroll view movement
	{
		[self setContentOffset:self.contentOffset animated:NO];
	}

	CGPoint newContentOffset = CGPointZero; // At top

	lastContentOffset = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);

	[self requeueAllThumbCells]; // Start off fresh

	_thumbCount = 0; // Reset the thumb count to zero

	NSUInteger thumbCount = [delegate numberOfThumbsInThumbsView:self];

	[self updateContentSize:thumbCount];
    
    _thumbCount = thumbCount;

	if (thumbCount > 0) // Have some thumbs
	{
		NSInteger boundsHeight = self.bounds.size.height;

		NSInteger maxY = (self.contentSize.height - boundsHeight);

		NSInteger minY = 0; maxY--; if (maxY < minY) maxY = minY; // Limits

		if (index < 0) index = 0; else if (index > thumbCount) index = (thumbCount - 1);

		NSInteger thumbY = ((index / _thumbsX) * _thumbSize.height); // Thumb Y

		NSInteger offsetY = (thumbY - (boundsHeight / 2) + (_thumbSize.height / 2));

		if (offsetY < minY) offsetY = minY; else if (offsetY > maxY) offsetY = maxY;

		newContentOffset.y = offsetY; // Calculated content offset Y position
	}

	newContentOffset.y -= self.contentInset.top; // Content inset adjust

    if (CGPointEqualToPoint(self.contentOffset, newContentOffset) == false) {
        [self setContentOffset:newContentOffset animated:NO];
    } else {
		[self scrollViewDidScroll:self];
    }

	[self flashScrollIndicators];
}

- (void)reloadThumbsContentOffset:(CGPoint)newContentOffset
{
	assert(delegate != nil); // Check delegate

	assert(CGSizeEqualToSize(_thumbSize, CGSizeZero) == false);

	if (self.decelerating == YES) // Stop scroll view movement
	{
		[self setContentOffset:self.contentOffset animated:NO];
	}

	lastContentOffset = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);

	[self requeueAllThumbCells]; // Start off fresh

	_thumbCount = 0; // Reset the thumb count to zero

	NSUInteger thumbCount = [delegate numberOfThumbsInThumbsView:self];

	[self updateContentSize:thumbCount];
    
    _thumbCount = thumbCount;

	if (thumbCount > 0) // Have some thumbs
	{
		NSInteger boundsHeight = self.bounds.size.height;

		NSInteger maxY = (self.contentSize.height - boundsHeight);

		NSInteger minY = 0; maxY--;
        
        if (maxY < minY) {
            maxY = minY; // Limits
        }

		NSInteger offsetY = newContentOffset.y; // Requested content offset Y

        if (offsetY < minY) {
            offsetY = minY;
        }else if (offsetY > maxY) {
            offsetY = maxY;
        }

		newContentOffset.y = offsetY;
        
        newContentOffset.x = 0.0f; // Validated
	}
	else // Zero (0) thumbs
	{
		newContentOffset = CGPointZero;
	}

	newContentOffset.y -= self.contentInset.top; // Content inset adjust

    if (CGPointEqualToPoint(self.contentOffset, newContentOffset) == false) {
		[self setContentOffset:newContentOffset animated:NO];
    }else {
		[self scrollViewDidScroll:self];
    }

	[self flashScrollIndicators];
}

- (void)refreshThumbWithIndex:(NSInteger)index
{
	for (HXPDFReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
	{
		if (tvCell.tag == index) // Found a visible thumb cell with the index value
		{
			if ([delegate respondsToSelector:@selector(thumbsView:refreshThumbCell:forIndex:)])
			{
				[delegate thumbsView:self refreshThumbCell:tvCell forIndex:index]; // Refresh
			}

            break;
		}
	}
}

- (void)refreshVisibleThumbs
{
	for (HXPDFReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
	{
		if ([delegate respondsToSelector:@selector(thumbsView:refreshThumbCell:forIndex:)])
		{
			[delegate thumbsView:self refreshThumbCell:tvCell forIndex:tvCell.tag]; // Refresh
		}
	}
}

- (CGPoint)insetContentOffset
{
	CGPoint insetContentOffset = self.contentOffset; // Offset

	insetContentOffset.y += self.contentInset.top; // Inset adjust

	return insetContentOffset; // Adjusted content offset
}

#pragma mark - UIGestureRecognizer action methods

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateRecognized) // Handle the tap
	{
		CGPoint point = [recognizer locationInView:recognizer.view]; // Tap location

		HXPDFReaderThumbView *tvCell = [self thumbCellContainingPoint:point]; // Look for cell

        if (tvCell != nil) {
            [delegate thumbsView:self didSelectThumbWithIndex:tvCell.tag];
        }
	}
}

- (void)handlePressGesture:(UILongPressGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan) // Handle the press
	{
		if ([delegate respondsToSelector:@selector(thumbsView:didPressThumbWithIndex:)])
		{
			CGPoint point = [recognizer locationInView:recognizer.view]; // Press location

			HXPDFReaderThumbView *tvCell = [self thumbCellContainingPoint:point]; // Look for cell

            if (tvCell != nil) {
                [delegate thumbsView:self didPressThumbWithIndex:tvCell.tag];
            }
		}
	}
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ((canUpdate == YES) && (_thumbCount > 0)) // Check flag and thumb count
	{
		if (CGPointEqualToPoint(scrollView.contentOffset, lastContentOffset) == false)
		{
			lastContentOffset = scrollView.contentOffset; // Work around a 'feature'

			CGRect visibleBounds = self.bounds; // Visible bounds in the scroll view

			NSMutableArray *requeueCells = [NSMutableArray array]; // Requeue cell list

			NSMutableIndexSet *visibleCellSet = [NSMutableIndexSet indexSet]; // Visible set

			for (HXPDFReaderThumbView *tvCell in thumbCellsVisible) // Enumerate visible cells
			{
                if (CGRectIntersectsRect(tvCell.frame, visibleBounds) == true) {
					[visibleCellSet addIndex:tvCell.tag];
                } else {
					[requeueCells addObject:tvCell];
                }
			}

			for (HXPDFReaderThumbView *tvCell in requeueCells) // Enumerate requeue cells
			{
				[self requeueThumbCell:tvCell]; // Requeue the thumb cell
			}

			NSMutableIndexSet *visibleIndexSet = [self visibleIndexSetForContentOffset];

			[visibleIndexSet enumerateIndexesUsingBlock: // Enumerate visible indexes
				^(NSUInteger index, BOOL *stop)
				{
					if ([visibleCellSet containsIndex:index] == NO) // Index not visible
					{
						CGRect thumbRect = [self thumbCellFrameForIndex:index]; // Frame

						HXPDFReaderThumbView *tvCell = [self dequeueThumbCellWithFrame:thumbRect];

                        [self->delegate thumbsView:self updateThumbCell:tvCell forIndex:index];

						tvCell.tag = index; tvCell.hidden = NO; // Tag and show it
					}
				}
			];
		}
	}
}

#pragma mark - UIResponder instance methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event]; // Message superclass

	if (touchedCell != nil) {
        [touchedCell showTouched:NO]; touchedCell = nil;
    }

	if (touches.count == 1) // Show selection on single touch
	{
		UITouch *touch = [touches anyObject]; // Get touch from set

		CGPoint point = [touch locationInView:touch.view]; // Touch location

		HXPDFReaderThumbView *tvCell = [self thumbCellContainingPoint:point]; // Look for cell

		if (tvCell != nil) {
            touchedCell = tvCell; [touchedCell showTouched:YES];
        }
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event]; // Message superclass

	if (touchedCell != nil) {
        [touchedCell showTouched:NO]; touchedCell = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event]; // Message superclass

	if (touchedCell != nil) {
        [touchedCell showTouched:NO]; touchedCell = nil;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event]; // Message superclass
}

@end
