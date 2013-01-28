#import "FDCollectionViewCell.h"
#import <FDTwitterKit/FDNullOrEmpty.h>


#pragma mark Constants

static const UIEdgeInsets Margin = { 8.0f, 8.0f, 8.0f, 8.0f };


#pragma mark - Class Extension

@interface FDCollectionViewCell ()

- (void)_initializeCollectionViewCell;
- (CGSize)_sizeOfContentsWithSize: (CGSize)size 
	shouldLayout: (BOOL)shoutLayout;


@end


#pragma mark - Class Variables


#pragma mark - Class Definition

@implementation FDCollectionViewCell
{
	@private __strong UILabel *_textLabel;
	@private __strong UILabel *_detailTextLabel;
}


#pragma mark - Properties

- (UILabel *)textLabel
{
	if (_textLabel == nil)
	{
		_textLabel = [[UILabel alloc] 
			initWithFrame: CGRectZero];
		
		_textLabel.opaque = NO;
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.textColor = [UIColor blackColor];
		_textLabel.highlightedTextColor = [UIColor whiteColor];
		_textLabel.font = [UIFont boldSystemFontOfSize: 14.0f];
		_textLabel.numberOfLines = 0;
		
		[self.contentView addSubview: _textLabel];
	}
	
	return _textLabel;
}

- (UILabel *)detailTextLabel
{
	if (_detailTextLabel == nil)
	{
		_detailTextLabel = [[UILabel alloc] 
			initWithFrame: CGRectZero];
		
		_detailTextLabel.opaque = NO;
		_detailTextLabel.backgroundColor = [UIColor clearColor];
		_detailTextLabel.textColor = [UIColor darkGrayColor];
		_detailTextLabel.highlightedTextColor = [UIColor whiteColor];
		_detailTextLabel.font = [UIFont systemFontOfSize: 14.0f];
		_detailTextLabel.numberOfLines = 0;
		
		[self.contentView addSubview: _detailTextLabel];
	}
	
	return _detailTextLabel;
}

- (void)setAccessoryView: (UIView *)accessoryView
{
	if(_accessoryView != accessoryView)
	{
		// Remove the old accessory view.
		[_accessoryView removeFromSuperview];
		
		_accessoryView = accessoryView;
		
		[self.contentView addSubview: _accessoryView];
	}
}


#pragma mark - Constructors

- (id)initWithFrame: (CGRect)frame
{
	// Abort if base initializer fails.
	if ((self = [super initWithFrame: frame]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeCollectionViewCell];
	
	// Return initialized instance.
	return self;
}

- (id)initWithCoder: (NSCoder *)coder
{
	// Abort if base initializer fails.
	if ((self = [super initWithCoder: coder]) == nil)
	{
		return nil;
	}
	
	// Initialize view.
	[self _initializeCollectionViewCell];
	
	// Return initialized instance.
	return self;
}


#pragma mark - Public Methods


#pragma mark - Overridden Methods

- (CGSize)sizeThatFits: (CGSize)size
{
	CGSize sizeThatFits = [self _sizeOfContentsWithSize: size 
		shouldLayout: NO];
	
	return sizeThatFits;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	[self _sizeOfContentsWithSize: self.bounds.size 
		shouldLayout: YES];
}

- (void)setHighlighted: (BOOL)highlighted
{
	// Call the base implementation.
	[super setHighlighted: highlighted];
	
	// Configure the collection view cell for the highlighted state.
	self.backgroundColor = highlighted ? [UIColor blueColor] : [UIColor whiteColor];
}

- (void)setSelected: (BOOL)selected
{
	// Call the base implementation.
	[super setSelected: selected];

	// Configure the collection view cell for the selected state.
	self.backgroundColor = selected ? [UIColor blueColor] : [UIColor whiteColor];
}


#pragma mark - Private Methods

- (void)_initializeCollectionViewCell
{
	// Initialize instance variables.
	UIView *dividerLine = [[UIView alloc] 
		initWithFrame: CGRectMake(0.0f, self.contentView.height - 1.0f, self.contentView.width, 1.0f)];
	dividerLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
		UIViewAutoresizingFlexibleTopMargin;
	dividerLine.backgroundColor = [UIColor blackColor];
	
	[self.contentView addSubview: dividerLine];
}

- (CGSize)_sizeOfContentsWithSize: (CGSize)size 
	shouldLayout: (BOOL)shoutLayout
{
	size.height = Margin.top + Margin.bottom;
	
	CGFloat availableWidth = size.width - Margin.left - Margin.right - _accessoryView.width;
	
	// Calculate the desired size of the text label if it had infinite height.
	CGSize desiredTextLabelSize = CGSizeZero;
	
	if (FDIsEmpty(_textLabel.text) == NO)
	{
		if (_textLabel.numberOfLines == 1)
		{
			desiredTextLabelSize = [_textLabel.text sizeWithFont: _textLabel.font 
				forWidth: availableWidth 
				lineBreakMode: _textLabel.lineBreakMode];
		}
		else
		{
			desiredTextLabelSize = [_textLabel.text sizeWithFont: _textLabel.font 
				constrainedToSize: CGSizeMake(availableWidth, CGFLOAT_MAX) 
				lineBreakMode: _textLabel.lineBreakMode];
		}
		
		size.height += desiredTextLabelSize.height;
	}
	
	// Calculate the desired size of the detail text label if it had infinite height.
	CGSize desiredDetailTextLabelSize = CGSizeZero;
	
	if (FDIsEmpty(_detailTextLabel.text) == NO)
	{
		if (_detailTextLabel.numberOfLines == 1)
		{
			desiredDetailTextLabelSize = [_detailTextLabel.text sizeWithFont: _detailTextLabel.font 
				forWidth: availableWidth 
				lineBreakMode: _detailTextLabel.lineBreakMode];
		}
		else
		{
			desiredDetailTextLabelSize = [_detailTextLabel.text sizeWithFont: _detailTextLabel.font 
				constrainedToSize: CGSizeMake(availableWidth, CGFLOAT_MAX) 
				lineBreakMode: _detailTextLabel.lineBreakMode];
		}
		
		size.height += 5.0f + desiredDetailTextLabelSize.height;
	}
	
	if (shoutLayout == YES)
	{
		_accessoryView.xOrigin = self.superview.width - _accessoryView.width;
		[_accessoryView alignVertically: UIViewVerticalAlignmentMiddle];
		
		_textLabel.xOrigin = Margin.left;
		_textLabel.width = availableWidth;
		_textLabel.height = desiredTextLabelSize.height;
		if (FDIsEmpty(_detailTextLabel.text) == YES)
		{
			[_textLabel alignVertically: UIViewVerticalAlignmentMiddle];
		}
		else
		{
			_textLabel.yOrigin = Margin.top;
		}
		
		_detailTextLabel.xOrigin = Margin.left;
		_detailTextLabel.yOrigin = CGRectGetMaxY([_textLabel frame]) + 5.0f;
		_detailTextLabel.width = availableWidth;
		_detailTextLabel.height = desiredDetailTextLabelSize.height;
	}
	
	return size;
}


@end