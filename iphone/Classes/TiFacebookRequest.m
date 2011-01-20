/**
 * Appcelerator Commercial License. Copyright (c) 2010 by Appcelerator, Inc.
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */

#import "TiFacebookRequest.h"


@implementation TiFacebookRequest

-(id)initWithPath:(NSString*)path_ callback:(KrollCallback*)callback_ module:(FacebookModule*)module_ graph:(BOOL)graph_
{
	if (self = [super init])
	{
		path = [path_ retain];
		callback = [callback_ retain];
		module = [module_ retain];
		graph = graph_;
		[self retain]; // since we're a delegate, we retain and release on callback
	}
	return self;
}

-(void)dealloc
{
	RELEASE_TO_NIL(path);
	RELEASE_TO_NIL(callback);
	RELEASE_TO_NIL(module);
	[super dealloc];
}

-(NSMutableDictionary*)eventParameters:(BOOL)yn
{
	if (graph)
	{
		return [NSMutableDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"graph",path,@"path",NUMBOOL(yn),@"success",nil];
	}
	else
	{
		return [NSMutableDictionary dictionaryWithObjectsAndKeys:NUMBOOL(NO),@"graph",path,@"method",NUMBOOL(yn),@"success",nil];
	}
}

#pragma mark Delegates

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest2*)request didFailWithError:(NSError*)error
{
	VerboseLog(@"[DEBUG] facebook didFailWithError = %@",error);
	NSMutableDictionary *event = [self eventParameters:NO];
	[event setObject:[error localizedDescription] forKey:@"error"];
	[module _fireEventToListener:@"result" withObject:event listener:callback thisObject:nil];
	[self autorelease];
}

/**
 * Called when a request returns and its response has been parsed into an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on thee format of the API response.
 */
- (void)request:(FBRequest2*)request didLoad:(id)result
{
	VerboseLog(@"[DEBUG] facebook didLoad");
	NSMutableDictionary *event = [self eventParameters:YES];
	[event setObject:result forKey:@"result"];
	[module _fireEventToListener:@"result" withObject:event listener:callback thisObject:nil];
	[self autorelease];
}

@end