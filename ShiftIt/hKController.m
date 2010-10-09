
/*
 ShiftIt: Resize windows with Hotkeys
 Copyright (C) 2010  Aravind
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import "hKController.h"


@implementation hKController

@synthesize hotKeys = hotKeys_;

static id hkController_ = nil;

+(id)getInstance{
	if(hkController_ == nil){
		hkController_ = [[hKController alloc] init];
	}
	return hkController_;
}

-(id)init{
	if(self == [super init]){
		hotKeys_ = [[NSMutableDictionary alloc] init];
	}
	return self;
}

-(void)dealloc{
	[super dealloc];
}


UInt32 convertToCarbon(NSUInteger inCocoaModifiers) {
    UInt32 carbModifiers = 0;
    if (inCocoaModifiers & NSAlphaShiftKeyMask){
        carbModifiers |= alphaLock;
    }
    if (inCocoaModifiers & NSShiftKeyMask){
        carbModifiers |= shiftKey;
    }
    if (inCocoaModifiers & NSControlKeyMask){
        carbModifiers |= controlKey;
    }
    if (inCocoaModifiers & NSAlternateKeyMask){
        carbModifiers |= optionKey;
    }
    if (inCocoaModifiers & NSCommandKeyMask){
        carbModifiers |= cmdKey;
    }
    return carbModifiers;
}

-(BOOL)registerHotKey:(SIHotKey*)hotKey{
	OSStatus error;
	EventHotKeyID hotKeyID;
	EventHotKeyRef hotKeyRef;
	
	hotKeyID.signature='SIHK';
	hotKeyID.id	= hotKey.hotKeyId;
	
	error = RegisterEventHotKey([hotKey keyCode], convertToCarbon([hotKey modifierCombo]), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
	
	
	if(error){
		return FALSE;
	}
	
	[hotKey setHotKeyRef:hotKeyRef];
	[hotKeys_ setObject:hotKey forKey:[NSNumber numberWithInt:[hotKey hotKeyId]]];
	
	return TRUE;
}

-(BOOL)unregisterHotKey:(SIHotKey*)hotKey{
	OSStatus error;
	EventHotKeyRef hotKeyRef = [hotKey hotKeyRef];
	error = UnregisterEventHotKey(hotKeyRef);
	if(error){
		return FALSE;
	}
	[hotKeys_ removeObjectForKey:[NSNumber numberWithInt:[hotKey hotKeyId]]];
	return TRUE;
}

-(BOOL)modifyHotKey:(SIHotKey*)hotKey{
	BOOL noError;
	noError = [self unregisterHotKey:[hotKeys_ objectForKey:[NSNumber numberWithInt:[hotKey hotKeyId]]]];
	if(noError){
		noError = [self registerHotKey:hotKey];
	}
	return !noError;
}

@end
