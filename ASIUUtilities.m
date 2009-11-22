/*
    ASIUUtilities.m
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
    23/11/2009 - Created by Shane Ambler
    
*/

#import "ASIUUtilities.h"


NSString* formatAsGB(float inputMB)
{
    // we show totals for entire usage history so supprt TB as well
    if( inputMB >= (MB_GB_Conversion*MB_GB_Conversion) )
	return [NSString stringWithFormat:@"%.2f TB",(inputMB/MB_GB_Conversion)/MB_GB_Conversion];
    else if( inputMB >= MB_GB_Conversion )
	return [NSString stringWithFormat:@"%.2f GB",inputMB/MB_GB_Conversion];
    else
	return [NSString stringWithFormat:@"%.1f MB",inputMB];
}

