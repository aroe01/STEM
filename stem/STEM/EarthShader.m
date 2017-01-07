//
//  EarthShader.m
//  Earth 2
//
//  Created by Ian on 10/15/15.
//  Copyright © 2015 Binary Gizmo. All rights reserved.
//

#import "EarthShader.h"

@implementation EarthShader

+ (NSString *)loadShader:(NSString *) shaderFileName
{
    
    // http://iphoneincubator.com/blog/data-management/how-to-read-a-file-from-your-application-bundle
    NSString *filePath = [[NSBundle mainBundle] pathForResource:shaderFileName ofType:@"glsl"];
    NSString *shader;
    NSError *error;
    if (filePath) {
        shader = [NSString stringWithContentsOfFile:filePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
        
        if (shader == nil) {
            // Method failed
            NSLog(@"Error loading shader file %@!", filePath);
            NSLog(@"Domain: %@", error.domain);
            NSLog(@"Error Code: %ld", (long)error.code);
            NSLog(@"Description: %@", [error localizedDescription]);
            NSLog(@"Reason: %@", [error localizedFailureReason]);
        } else {
            // Method succeeded
            NSLog(@"Shader loaded!");
//            NSLog(@"%@", shader);
        }
    }
    
    return shader;
}

+ (NSString *)setupEarthShader:(MaplyBaseViewController *)viewC
{
    NSLog(@"Setting up Shader");

    NSString *vertexShader = [EarthShader loadShader:@"EarthVertexShader"];
    NSString *fragmentShader = [EarthShader loadShader:@"EarthFragmentShader"];
    
    NSString *shaderName = @"Earth Shader";
//    NSString *sceneName = @"kMaplyShaderDefaultTri";
    
    MaplyShader *shader = [[MaplyShader alloc] initWithName:shaderName
                                                     vertex: vertexShader
                                                   fragment: fragmentShader
                                                      viewC:viewC];
    if (shader.valid)
    {
//        [viewC addShaderProgram:shader sceneName:sceneName];
        [viewC addShaderProgram:shader sceneName:shaderName];
        
        NSLog(@"Shader compiled OK");
    } else {
        shaderName = nil;
        NSLog(@"Shader failed to compile: %@",[shader getError]);
    }
    
    return shaderName;
}

@end


