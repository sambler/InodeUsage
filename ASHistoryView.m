/*
    ASHistoryView.m
    InodeUsage
    
    Copyright (c) 2009, Shane Ambler
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without 
    modification, are permitted provided that the following conditions are met:

        *   Redistributions of source code must retain the above copyright
            notice, this list of conditions and the following disclaimer.
        *   Redistributions in binary form must reproduce the above copyright 
            notice, this list of conditions and the following disclaimer in the
            documentation and/or other materials provided with the distribution.
            
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
******************************************************************************
    Change History :-
    03/11/2009 - Created by Shane Ambler
    22/11/2009 - added cour drawing to the history graph by Shane Ambler
    
*/

#import "ASHistoryView.h"
#import "ASInternetUsageUserDefaults.h"
#import "ASIUUtilities.h"


@implementation ASHistoryView

- (id)initWithFrame:(NSRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        mCurrentPeriod = nil;
        mDaysInPeriod = 0;
        mDaysToShow = 0;
        mSpacePerDay = 0;
        mAverageUsage = 0;
        mFillColour = nil;
        mBorderColour = nil;
        
    }
    return self;
}

- (void) dealloc {
    [mCurrentPeriod release];
    [mFillColour release];
    [mBorderColour release];
    [mInfoField release];
    
    [super dealloc];
}

-(void)setPeriodData:(ASHistoryPeriod*)periodData withAverage:(float)inAverage
{
    mCurrentPeriod = [periodData retain];
    mAverageUsage = inAverage;
    
    mDaysToShow = [[NSUserDefaults standardUserDefaults]integerForKey:ASIUHistoryShowLimit];
    
    if ( mDaysToShow > [mCurrentPeriod entriesCount] )
        mDaysToShow = [mCurrentPeriod entriesCount];
    
    mSpacePerDay = [self frame].size.width/mDaysToShow;
    
    [self setNeedsDisplay:true];
}

-(void)setInfoField:(NSTextField*)inField
{
    [mInfoField release];
    mInfoField = [inField retain];
}

-(void)updateColours
{
    [mBorderColour release];
    mBorderColour = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:ASIUHistoryBorderColour]];
    [mBorderColour retain];
    [mFillColour release];
    mFillColour = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:ASIUHistoryFillColour]];
    [mFillColour retain];
}

- (void)drawRect:(NSRect)rect
{
    NSRect usageRect;
    int x, idxStart, idxEnd;
    
    [[NSColor whiteColor]set];
    [NSBezierPath fillRect:rect];
    
    if( mCurrentPeriod == nil ) return;
    
    [NSBezierPath setDefaultLineWidth:2.0];
    [mFillColour setFill];
    [mBorderColour setStroke];
    
    idxEnd = [mCurrentPeriod entriesCount];
    idxStart = idxEnd - mDaysToShow;
    
    for(x=idxStart;x<idxEnd;x++)
    {
        usageRect.origin.x = (mSpacePerDay * (x-idxStart))+1;
        usageRect.origin.y = -2.0;
        usageRect.size.width = mSpacePerDay * 0.8; //leave a little gap between
        usageRect.size.height = ([[[mCurrentPeriod data] objectAtIndex:x]usage]/[mCurrentPeriod highestDailyUsage])*rect.size.height;
        
        [NSBezierPath fillRect:usageRect];
        [NSBezierPath strokeRect:usageRect];
    }
    
    // draw the average line
    float avgLinePos = ((mAverageUsage/[mCurrentPeriod highestDailyUsage])*rect.size.height) - 2.0;
    [NSBezierPath setDefaultLineWidth:1.0];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(0,avgLinePos) toPoint:NSMakePoint([self bounds].size.width,avgLinePos)];
}

-(void)mouseMoved:(NSEvent*)theEvent
{
    int idxLocation;
    NSPoint p;
    
    p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if( ! NSPointInRect(p,[self bounds]) )
        [mInfoField setStringValue:@""];
    else
    {
        idxLocation = (p.x / mSpacePerDay) + ([[mCurrentPeriod data]count]-mDaysToShow);
        
        [mInfoField setStringValue:[NSString stringWithFormat:@"%@ : %@",[[[[mCurrentPeriod data] objectAtIndex:idxLocation]storedDay] descriptionWithCalendarFormat:@"%a %d/%m/%Y"],formatAsGB([[[mCurrentPeriod data] objectAtIndex:idxLocation]usage])]];
        
        // for debugging - show index used to access history entry and total entries shown
        //[mInfoField setStringValue:[NSString stringWithFormat:@"(%i-%i-%i) %@",idxLocation,[[mCurrentPeriod data]count],mDaysToShow,[mInfoField stringValue]]];
    }
}


@end
