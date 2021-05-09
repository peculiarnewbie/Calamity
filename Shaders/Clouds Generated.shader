Shader "Unlit Master"
{
    Properties
    {
        _ProjectionRotation("Rotate Projection", Vector) = (1, 0, 0, 0)
        _NoiseScale("Noise Scale", Float) = 10
        _CloudSpeed("Cloud Speed", Float) = 0.1
        _CloudHeight("Cloud Height", Float) = 1
        _NoiseRemap("Remap", Vector) = (0, 1, -1, 1)
        _ValleyColor("Valley Color", Color) = (0, 0, 0, 0)
        _PeakColor("Peak Color", Color) = (1, 1, 1, 0)
        _PeakSmooth("Peak Color Smooth", Float) = 0
        _ValleySmooth("Valley Color Smooth", Float) = 1
        _NoisePower("Noise Power", Float) = 2
        _BaseScale("Base Scale", Float) = 5
        _BaseSpeed("Base Speed", Float) = 0.2
        _BaseStrength("Base Strength", Float) = 2
        _EmissionStrength("Emission Strength", Float) = 2
        _CurvatureRadius("Curvature Radius", Float) = 1
        _FresnelPower("Fresnel Power", Float) = 1
        _FresnelOpacity("Fresnel Opacity", Float) = 1
        _FadeDepth("Fade Depth", Float) = 100
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent+0"
        }
        
        Pass
        {
            Name "Pass"
            Tags 
            { 
                // LightMode: <None>
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
            
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
        
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>
            
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS 
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_UNLIT
            #define REQUIRE_DEPTH_TEXTURE
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _ProjectionRotation;
            float _NoiseScale;
            float _CloudSpeed;
            float _CloudHeight;
            float4 _NoiseRemap;
            float4 _ValleyColor;
            float4 _PeakColor;
            float _PeakSmooth;
            float _ValleySmooth;
            float _NoisePower;
            float _BaseScale;
            float _BaseSpeed;
            float _BaseStrength;
            float _EmissionStrength;
            float _CurvatureRadius;
            float _FresnelPower;
            float _FresnelOpacity;
            float _FadeDepth;
            CBUFFER_END
        
            // Graph Functions
            
            void Unity_Distance_float3(float3 A, float3 B, out float Out)
            {
                Out = distance(A, B);
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
            {
                Rotation = radians(Rotation);
            
                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;
                
                Axis = normalize(Axis);
            
                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                        };
            
                Out = mul(rot_mat,  In);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }
            
            
            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }
            
            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            { 
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }
            
            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
            {
                Out = lerp(A, B, T);
            }
            
            void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
            {
                Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }
            
            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }
            
            void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 WorldSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
                float3 WorldSpacePosition;
                float3 TimeParameters;
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float _Distance_9FA356F2_Out_2;
                Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_9FA356F2_Out_2);
                float _Property_FFEF3624_Out_0 = _CurvatureRadius;
                float _Divide_546B609_Out_2;
                Unity_Divide_float(_Distance_9FA356F2_Out_2, _Property_FFEF3624_Out_0, _Divide_546B609_Out_2);
                float _Power_F12EFF02_Out_2;
                Unity_Power_float(_Distance_9FA356F2_Out_2, _Divide_546B609_Out_2, _Power_F12EFF02_Out_2);
                float3 _Multiply_CBE251EB_Out_2;
                Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_F12EFF02_Out_2.xxx), _Multiply_CBE251EB_Out_2);
                float _Property_345ACFDB_Out_0 = _PeakSmooth;
                float _Property_2C7843EC_Out_0 = _ValleySmooth;
                float4 _Property_9F876CEA_Out_0 = _ProjectionRotation;
                float _Split_2A508F07_R_1 = _Property_9F876CEA_Out_0[0];
                float _Split_2A508F07_G_2 = _Property_9F876CEA_Out_0[1];
                float _Split_2A508F07_B_3 = _Property_9F876CEA_Out_0[2];
                float _Split_2A508F07_A_4 = _Property_9F876CEA_Out_0[3];
                float3 _RotateAboutAxis_65218D77_Out_3;
                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_9F876CEA_Out_0.xyz), _Split_2A508F07_A_4, _RotateAboutAxis_65218D77_Out_3);
                float _Property_265400EA_Out_0 = _CloudSpeed;
                float _Multiply_68505AAE_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_265400EA_Out_0, _Multiply_68505AAE_Out_2);
                float2 _TilingAndOffset_466B1C44_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_68505AAE_Out_2.xx), _TilingAndOffset_466B1C44_Out_3);
                float _Property_F3DD64DA_Out_0 = _NoiseScale;
                float _GradientNoise_2C184089_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_466B1C44_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_2C184089_Out_2);
                float2 _TilingAndOffset_BB452560_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_BB452560_Out_3);
                float _GradientNoise_35CCE017_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_BB452560_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_35CCE017_Out_2);
                float _Add_5B6CBFA1_Out_2;
                Unity_Add_float(_GradientNoise_2C184089_Out_2, _GradientNoise_35CCE017_Out_2, _Add_5B6CBFA1_Out_2);
                float _Divide_B48CBC03_Out_2;
                Unity_Divide_float(_Add_5B6CBFA1_Out_2, 2, _Divide_B48CBC03_Out_2);
                float _Saturate_DE8CD7FB_Out_1;
                Unity_Saturate_float(_Divide_B48CBC03_Out_2, _Saturate_DE8CD7FB_Out_1);
                float _Property_6ADFA1CC_Out_0 = _NoisePower;
                float _Power_B60CE997_Out_2;
                Unity_Power_float(_Saturate_DE8CD7FB_Out_1, _Property_6ADFA1CC_Out_0, _Power_B60CE997_Out_2);
                float4 _Property_58330B6_Out_0 = _NoiseRemap;
                float _Split_AF742FBB_R_1 = _Property_58330B6_Out_0[0];
                float _Split_AF742FBB_G_2 = _Property_58330B6_Out_0[1];
                float _Split_AF742FBB_B_3 = _Property_58330B6_Out_0[2];
                float _Split_AF742FBB_A_4 = _Property_58330B6_Out_0[3];
                float4 _Combine_695E1C91_RGBA_4;
                float3 _Combine_695E1C91_RGB_5;
                float2 _Combine_695E1C91_RG_6;
                Unity_Combine_float(_Split_AF742FBB_R_1, _Split_AF742FBB_G_2, 0, 0, _Combine_695E1C91_RGBA_4, _Combine_695E1C91_RGB_5, _Combine_695E1C91_RG_6);
                float4 _Combine_76EBDC49_RGBA_4;
                float3 _Combine_76EBDC49_RGB_5;
                float2 _Combine_76EBDC49_RG_6;
                Unity_Combine_float(_Split_AF742FBB_B_3, _Split_AF742FBB_A_4, 0, 0, _Combine_76EBDC49_RGBA_4, _Combine_76EBDC49_RGB_5, _Combine_76EBDC49_RG_6);
                float _Remap_BDA469EE_Out_3;
                Unity_Remap_float(_Power_B60CE997_Out_2, _Combine_695E1C91_RG_6, _Combine_76EBDC49_RG_6, _Remap_BDA469EE_Out_3);
                float _Absolute_E40EC47E_Out_1;
                Unity_Absolute_float(_Remap_BDA469EE_Out_3, _Absolute_E40EC47E_Out_1);
                float _Smoothstep_D1147D2C_Out_3;
                Unity_Smoothstep_float(_Property_345ACFDB_Out_0, _Property_2C7843EC_Out_0, _Absolute_E40EC47E_Out_1, _Smoothstep_D1147D2C_Out_3);
                float _Property_DF15A01D_Out_0 = _BaseSpeed;
                float _Multiply_EBF2B910_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_DF15A01D_Out_0, _Multiply_EBF2B910_Out_2);
                float2 _TilingAndOffset_93B5B078_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_EBF2B910_Out_2.xx), _TilingAndOffset_93B5B078_Out_3);
                float _Property_33C67278_Out_0 = _BaseScale;
                float _GradientNoise_4F44AE48_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_93B5B078_Out_3, _Property_33C67278_Out_0, _GradientNoise_4F44AE48_Out_2);
                float _Property_83351417_Out_0 = _BaseStrength;
                float _Multiply_71765D64_Out_2;
                Unity_Multiply_float(_GradientNoise_4F44AE48_Out_2, _Property_83351417_Out_0, _Multiply_71765D64_Out_2);
                float _Add_7ACD772F_Out_2;
                Unity_Add_float(_Smoothstep_D1147D2C_Out_3, _Multiply_71765D64_Out_2, _Add_7ACD772F_Out_2);
                float _Add_E06E68EA_Out_2;
                Unity_Add_float(1, _Property_83351417_Out_0, _Add_E06E68EA_Out_2);
                float _Divide_7F230043_Out_2;
                Unity_Divide_float(_Add_7ACD772F_Out_2, _Add_E06E68EA_Out_2, _Divide_7F230043_Out_2);
                float3 _Multiply_484E11C9_Out_2;
                Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_7F230043_Out_2.xxx), _Multiply_484E11C9_Out_2);
                float _Property_5333B30F_Out_0 = _CloudHeight;
                float3 _Multiply_39CA1DCA_Out_2;
                Unity_Multiply_float(_Multiply_484E11C9_Out_2, (_Property_5333B30F_Out_0.xxx), _Multiply_39CA1DCA_Out_2);
                float3 _Add_F738762A_Out_2;
                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_39CA1DCA_Out_2, _Add_F738762A_Out_2);
                float3 _Add_715D9DD7_Out_2;
                Unity_Add_float3(_Multiply_CBE251EB_Out_2, _Add_F738762A_Out_2, _Add_715D9DD7_Out_2);
                description.VertexPosition = _Add_715D9DD7_Out_2;
                description.VertexNormal = IN.ObjectSpaceNormal;
                description.VertexTangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                float3 WorldSpaceNormal;
                float3 WorldSpaceViewDirection;
                float3 WorldSpacePosition;
                float4 ScreenPosition;
                float3 TimeParameters;
            };
            
            struct SurfaceDescription
            {
                float3 Color;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_394C2F43_Out_0 = _ValleyColor;
                float4 _Property_C10659F0_Out_0 = _PeakColor;
                float _Property_345ACFDB_Out_0 = _PeakSmooth;
                float _Property_2C7843EC_Out_0 = _ValleySmooth;
                float4 _Property_9F876CEA_Out_0 = _ProjectionRotation;
                float _Split_2A508F07_R_1 = _Property_9F876CEA_Out_0[0];
                float _Split_2A508F07_G_2 = _Property_9F876CEA_Out_0[1];
                float _Split_2A508F07_B_3 = _Property_9F876CEA_Out_0[2];
                float _Split_2A508F07_A_4 = _Property_9F876CEA_Out_0[3];
                float3 _RotateAboutAxis_65218D77_Out_3;
                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_9F876CEA_Out_0.xyz), _Split_2A508F07_A_4, _RotateAboutAxis_65218D77_Out_3);
                float _Property_265400EA_Out_0 = _CloudSpeed;
                float _Multiply_68505AAE_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_265400EA_Out_0, _Multiply_68505AAE_Out_2);
                float2 _TilingAndOffset_466B1C44_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_68505AAE_Out_2.xx), _TilingAndOffset_466B1C44_Out_3);
                float _Property_F3DD64DA_Out_0 = _NoiseScale;
                float _GradientNoise_2C184089_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_466B1C44_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_2C184089_Out_2);
                float2 _TilingAndOffset_BB452560_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_BB452560_Out_3);
                float _GradientNoise_35CCE017_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_BB452560_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_35CCE017_Out_2);
                float _Add_5B6CBFA1_Out_2;
                Unity_Add_float(_GradientNoise_2C184089_Out_2, _GradientNoise_35CCE017_Out_2, _Add_5B6CBFA1_Out_2);
                float _Divide_B48CBC03_Out_2;
                Unity_Divide_float(_Add_5B6CBFA1_Out_2, 2, _Divide_B48CBC03_Out_2);
                float _Saturate_DE8CD7FB_Out_1;
                Unity_Saturate_float(_Divide_B48CBC03_Out_2, _Saturate_DE8CD7FB_Out_1);
                float _Property_6ADFA1CC_Out_0 = _NoisePower;
                float _Power_B60CE997_Out_2;
                Unity_Power_float(_Saturate_DE8CD7FB_Out_1, _Property_6ADFA1CC_Out_0, _Power_B60CE997_Out_2);
                float4 _Property_58330B6_Out_0 = _NoiseRemap;
                float _Split_AF742FBB_R_1 = _Property_58330B6_Out_0[0];
                float _Split_AF742FBB_G_2 = _Property_58330B6_Out_0[1];
                float _Split_AF742FBB_B_3 = _Property_58330B6_Out_0[2];
                float _Split_AF742FBB_A_4 = _Property_58330B6_Out_0[3];
                float4 _Combine_695E1C91_RGBA_4;
                float3 _Combine_695E1C91_RGB_5;
                float2 _Combine_695E1C91_RG_6;
                Unity_Combine_float(_Split_AF742FBB_R_1, _Split_AF742FBB_G_2, 0, 0, _Combine_695E1C91_RGBA_4, _Combine_695E1C91_RGB_5, _Combine_695E1C91_RG_6);
                float4 _Combine_76EBDC49_RGBA_4;
                float3 _Combine_76EBDC49_RGB_5;
                float2 _Combine_76EBDC49_RG_6;
                Unity_Combine_float(_Split_AF742FBB_B_3, _Split_AF742FBB_A_4, 0, 0, _Combine_76EBDC49_RGBA_4, _Combine_76EBDC49_RGB_5, _Combine_76EBDC49_RG_6);
                float _Remap_BDA469EE_Out_3;
                Unity_Remap_float(_Power_B60CE997_Out_2, _Combine_695E1C91_RG_6, _Combine_76EBDC49_RG_6, _Remap_BDA469EE_Out_3);
                float _Absolute_E40EC47E_Out_1;
                Unity_Absolute_float(_Remap_BDA469EE_Out_3, _Absolute_E40EC47E_Out_1);
                float _Smoothstep_D1147D2C_Out_3;
                Unity_Smoothstep_float(_Property_345ACFDB_Out_0, _Property_2C7843EC_Out_0, _Absolute_E40EC47E_Out_1, _Smoothstep_D1147D2C_Out_3);
                float _Property_DF15A01D_Out_0 = _BaseSpeed;
                float _Multiply_EBF2B910_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_DF15A01D_Out_0, _Multiply_EBF2B910_Out_2);
                float2 _TilingAndOffset_93B5B078_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_EBF2B910_Out_2.xx), _TilingAndOffset_93B5B078_Out_3);
                float _Property_33C67278_Out_0 = _BaseScale;
                float _GradientNoise_4F44AE48_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_93B5B078_Out_3, _Property_33C67278_Out_0, _GradientNoise_4F44AE48_Out_2);
                float _Property_83351417_Out_0 = _BaseStrength;
                float _Multiply_71765D64_Out_2;
                Unity_Multiply_float(_GradientNoise_4F44AE48_Out_2, _Property_83351417_Out_0, _Multiply_71765D64_Out_2);
                float _Add_7ACD772F_Out_2;
                Unity_Add_float(_Smoothstep_D1147D2C_Out_3, _Multiply_71765D64_Out_2, _Add_7ACD772F_Out_2);
                float _Add_E06E68EA_Out_2;
                Unity_Add_float(1, _Property_83351417_Out_0, _Add_E06E68EA_Out_2);
                float _Divide_7F230043_Out_2;
                Unity_Divide_float(_Add_7ACD772F_Out_2, _Add_E06E68EA_Out_2, _Divide_7F230043_Out_2);
                float4 _Lerp_4EC5C6FF_Out_3;
                Unity_Lerp_float4(_Property_394C2F43_Out_0, _Property_C10659F0_Out_0, (_Divide_7F230043_Out_2.xxxx), _Lerp_4EC5C6FF_Out_3);
                float _Property_2B056706_Out_0 = _FresnelPower;
                float _FresnelEffect_F30AB523_Out_3;
                Unity_FresnelEffect_float(IN.WorldSpaceNormal, IN.WorldSpaceViewDirection, _Property_2B056706_Out_0, _FresnelEffect_F30AB523_Out_3);
                float _Multiply_D0E46439_Out_2;
                Unity_Multiply_float(_Divide_7F230043_Out_2, _FresnelEffect_F30AB523_Out_3, _Multiply_D0E46439_Out_2);
                float _Property_3C100781_Out_0 = _FresnelOpacity;
                float _Multiply_5DAE61F0_Out_2;
                Unity_Multiply_float(_Multiply_D0E46439_Out_2, _Property_3C100781_Out_0, _Multiply_5DAE61F0_Out_2);
                float4 _Add_2ADFBAF_Out_2;
                Unity_Add_float4(_Lerp_4EC5C6FF_Out_3, (_Multiply_5DAE61F0_Out_2.xxxx), _Add_2ADFBAF_Out_2);
                float _Property_586983_Out_0 = _EmissionStrength;
                float4 _Multiply_80BF31C5_Out_2;
                Unity_Multiply_float(_Add_2ADFBAF_Out_2, (_Property_586983_Out_0.xxxx), _Multiply_80BF31C5_Out_2);
                float4 _Add_BC22C625_Out_2;
                Unity_Add_float4(_Add_2ADFBAF_Out_2, _Multiply_80BF31C5_Out_2, _Add_BC22C625_Out_2);
                float4 _Lerp_22F038ED_Out_3;
                Unity_Lerp_float4(_Add_2ADFBAF_Out_2, _Add_BC22C625_Out_2, _Add_2ADFBAF_Out_2, _Lerp_22F038ED_Out_3);
                float _SceneDepth_3475ECEB_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3475ECEB_Out_1);
                float4 _ScreenPosition_7B8291C2_Out_0 = IN.ScreenPosition;
                float _Split_CA18A3D4_R_1 = _ScreenPosition_7B8291C2_Out_0[0];
                float _Split_CA18A3D4_G_2 = _ScreenPosition_7B8291C2_Out_0[1];
                float _Split_CA18A3D4_B_3 = _ScreenPosition_7B8291C2_Out_0[2];
                float _Split_CA18A3D4_A_4 = _ScreenPosition_7B8291C2_Out_0[3];
                float _Subtract_33AD8FCC_Out_2;
                Unity_Subtract_float(_Split_CA18A3D4_A_4, 1, _Subtract_33AD8FCC_Out_2);
                float _Subtract_F8C04A4A_Out_2;
                Unity_Subtract_float(_SceneDepth_3475ECEB_Out_1, _Subtract_33AD8FCC_Out_2, _Subtract_F8C04A4A_Out_2);
                float _Property_6925EAED_Out_0 = _FadeDepth;
                float _Divide_1AD2400A_Out_2;
                Unity_Divide_float(_Subtract_F8C04A4A_Out_2, _Property_6925EAED_Out_0, _Divide_1AD2400A_Out_2);
                float _Saturate_DCBD955D_Out_1;
                Unity_Saturate_float(_Divide_1AD2400A_Out_2, _Saturate_DCBD955D_Out_1);
                surface.Color = (_Lerp_22F038ED_Out_3.xyz);
                surface.Alpha = _Saturate_DCBD955D_Out_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float3 interp02 : TEXCOORD2;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                output.interp01.xyz = input.normalWS;
                output.interp02.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                output.normalWS = input.interp01.xyz;
                output.viewDirectionWS = input.interp02.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =           input.normalOS;
                output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =          input.tangentOS;
                output.ObjectSpacePosition =         input.positionOS;
                output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                output.TimeParameters =              _TimeParameters.xyz;
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            	float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);
            
            
                output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
            
            
                output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
                output.WorldSpacePosition =          input.positionWS;
                output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
            ENDHLSL
        }
        
        Pass
        {
            Name "ShadowCaster"
            Tags 
            { 
                "LightMode" = "ShadowCaster"
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            // ColorMask: <None>
            
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
        
            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>
            
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS 
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_SHADOWCASTER
            #define REQUIRE_DEPTH_TEXTURE
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _ProjectionRotation;
            float _NoiseScale;
            float _CloudSpeed;
            float _CloudHeight;
            float4 _NoiseRemap;
            float4 _ValleyColor;
            float4 _PeakColor;
            float _PeakSmooth;
            float _ValleySmooth;
            float _NoisePower;
            float _BaseScale;
            float _BaseSpeed;
            float _BaseStrength;
            float _EmissionStrength;
            float _CurvatureRadius;
            float _FresnelPower;
            float _FresnelOpacity;
            float _FadeDepth;
            CBUFFER_END
        
            // Graph Functions
            
            void Unity_Distance_float3(float3 A, float3 B, out float Out)
            {
                Out = distance(A, B);
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
            {
                Rotation = radians(Rotation);
            
                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;
                
                Axis = normalize(Axis);
            
                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                        };
            
                Out = mul(rot_mat,  In);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }
            
            
            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }
            
            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            { 
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }
            
            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 WorldSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
                float3 WorldSpacePosition;
                float3 TimeParameters;
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float _Distance_9FA356F2_Out_2;
                Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_9FA356F2_Out_2);
                float _Property_FFEF3624_Out_0 = _CurvatureRadius;
                float _Divide_546B609_Out_2;
                Unity_Divide_float(_Distance_9FA356F2_Out_2, _Property_FFEF3624_Out_0, _Divide_546B609_Out_2);
                float _Power_F12EFF02_Out_2;
                Unity_Power_float(_Distance_9FA356F2_Out_2, _Divide_546B609_Out_2, _Power_F12EFF02_Out_2);
                float3 _Multiply_CBE251EB_Out_2;
                Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_F12EFF02_Out_2.xxx), _Multiply_CBE251EB_Out_2);
                float _Property_345ACFDB_Out_0 = _PeakSmooth;
                float _Property_2C7843EC_Out_0 = _ValleySmooth;
                float4 _Property_9F876CEA_Out_0 = _ProjectionRotation;
                float _Split_2A508F07_R_1 = _Property_9F876CEA_Out_0[0];
                float _Split_2A508F07_G_2 = _Property_9F876CEA_Out_0[1];
                float _Split_2A508F07_B_3 = _Property_9F876CEA_Out_0[2];
                float _Split_2A508F07_A_4 = _Property_9F876CEA_Out_0[3];
                float3 _RotateAboutAxis_65218D77_Out_3;
                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_9F876CEA_Out_0.xyz), _Split_2A508F07_A_4, _RotateAboutAxis_65218D77_Out_3);
                float _Property_265400EA_Out_0 = _CloudSpeed;
                float _Multiply_68505AAE_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_265400EA_Out_0, _Multiply_68505AAE_Out_2);
                float2 _TilingAndOffset_466B1C44_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_68505AAE_Out_2.xx), _TilingAndOffset_466B1C44_Out_3);
                float _Property_F3DD64DA_Out_0 = _NoiseScale;
                float _GradientNoise_2C184089_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_466B1C44_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_2C184089_Out_2);
                float2 _TilingAndOffset_BB452560_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_BB452560_Out_3);
                float _GradientNoise_35CCE017_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_BB452560_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_35CCE017_Out_2);
                float _Add_5B6CBFA1_Out_2;
                Unity_Add_float(_GradientNoise_2C184089_Out_2, _GradientNoise_35CCE017_Out_2, _Add_5B6CBFA1_Out_2);
                float _Divide_B48CBC03_Out_2;
                Unity_Divide_float(_Add_5B6CBFA1_Out_2, 2, _Divide_B48CBC03_Out_2);
                float _Saturate_DE8CD7FB_Out_1;
                Unity_Saturate_float(_Divide_B48CBC03_Out_2, _Saturate_DE8CD7FB_Out_1);
                float _Property_6ADFA1CC_Out_0 = _NoisePower;
                float _Power_B60CE997_Out_2;
                Unity_Power_float(_Saturate_DE8CD7FB_Out_1, _Property_6ADFA1CC_Out_0, _Power_B60CE997_Out_2);
                float4 _Property_58330B6_Out_0 = _NoiseRemap;
                float _Split_AF742FBB_R_1 = _Property_58330B6_Out_0[0];
                float _Split_AF742FBB_G_2 = _Property_58330B6_Out_0[1];
                float _Split_AF742FBB_B_3 = _Property_58330B6_Out_0[2];
                float _Split_AF742FBB_A_4 = _Property_58330B6_Out_0[3];
                float4 _Combine_695E1C91_RGBA_4;
                float3 _Combine_695E1C91_RGB_5;
                float2 _Combine_695E1C91_RG_6;
                Unity_Combine_float(_Split_AF742FBB_R_1, _Split_AF742FBB_G_2, 0, 0, _Combine_695E1C91_RGBA_4, _Combine_695E1C91_RGB_5, _Combine_695E1C91_RG_6);
                float4 _Combine_76EBDC49_RGBA_4;
                float3 _Combine_76EBDC49_RGB_5;
                float2 _Combine_76EBDC49_RG_6;
                Unity_Combine_float(_Split_AF742FBB_B_3, _Split_AF742FBB_A_4, 0, 0, _Combine_76EBDC49_RGBA_4, _Combine_76EBDC49_RGB_5, _Combine_76EBDC49_RG_6);
                float _Remap_BDA469EE_Out_3;
                Unity_Remap_float(_Power_B60CE997_Out_2, _Combine_695E1C91_RG_6, _Combine_76EBDC49_RG_6, _Remap_BDA469EE_Out_3);
                float _Absolute_E40EC47E_Out_1;
                Unity_Absolute_float(_Remap_BDA469EE_Out_3, _Absolute_E40EC47E_Out_1);
                float _Smoothstep_D1147D2C_Out_3;
                Unity_Smoothstep_float(_Property_345ACFDB_Out_0, _Property_2C7843EC_Out_0, _Absolute_E40EC47E_Out_1, _Smoothstep_D1147D2C_Out_3);
                float _Property_DF15A01D_Out_0 = _BaseSpeed;
                float _Multiply_EBF2B910_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_DF15A01D_Out_0, _Multiply_EBF2B910_Out_2);
                float2 _TilingAndOffset_93B5B078_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_EBF2B910_Out_2.xx), _TilingAndOffset_93B5B078_Out_3);
                float _Property_33C67278_Out_0 = _BaseScale;
                float _GradientNoise_4F44AE48_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_93B5B078_Out_3, _Property_33C67278_Out_0, _GradientNoise_4F44AE48_Out_2);
                float _Property_83351417_Out_0 = _BaseStrength;
                float _Multiply_71765D64_Out_2;
                Unity_Multiply_float(_GradientNoise_4F44AE48_Out_2, _Property_83351417_Out_0, _Multiply_71765D64_Out_2);
                float _Add_7ACD772F_Out_2;
                Unity_Add_float(_Smoothstep_D1147D2C_Out_3, _Multiply_71765D64_Out_2, _Add_7ACD772F_Out_2);
                float _Add_E06E68EA_Out_2;
                Unity_Add_float(1, _Property_83351417_Out_0, _Add_E06E68EA_Out_2);
                float _Divide_7F230043_Out_2;
                Unity_Divide_float(_Add_7ACD772F_Out_2, _Add_E06E68EA_Out_2, _Divide_7F230043_Out_2);
                float3 _Multiply_484E11C9_Out_2;
                Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_7F230043_Out_2.xxx), _Multiply_484E11C9_Out_2);
                float _Property_5333B30F_Out_0 = _CloudHeight;
                float3 _Multiply_39CA1DCA_Out_2;
                Unity_Multiply_float(_Multiply_484E11C9_Out_2, (_Property_5333B30F_Out_0.xxx), _Multiply_39CA1DCA_Out_2);
                float3 _Add_F738762A_Out_2;
                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_39CA1DCA_Out_2, _Add_F738762A_Out_2);
                float3 _Add_715D9DD7_Out_2;
                Unity_Add_float3(_Multiply_CBE251EB_Out_2, _Add_F738762A_Out_2, _Add_715D9DD7_Out_2);
                description.VertexPosition = _Add_715D9DD7_Out_2;
                description.VertexNormal = IN.ObjectSpaceNormal;
                description.VertexTangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                float3 WorldSpacePosition;
                float4 ScreenPosition;
            };
            
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _SceneDepth_3475ECEB_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3475ECEB_Out_1);
                float4 _ScreenPosition_7B8291C2_Out_0 = IN.ScreenPosition;
                float _Split_CA18A3D4_R_1 = _ScreenPosition_7B8291C2_Out_0[0];
                float _Split_CA18A3D4_G_2 = _ScreenPosition_7B8291C2_Out_0[1];
                float _Split_CA18A3D4_B_3 = _ScreenPosition_7B8291C2_Out_0[2];
                float _Split_CA18A3D4_A_4 = _ScreenPosition_7B8291C2_Out_0[3];
                float _Subtract_33AD8FCC_Out_2;
                Unity_Subtract_float(_Split_CA18A3D4_A_4, 1, _Subtract_33AD8FCC_Out_2);
                float _Subtract_F8C04A4A_Out_2;
                Unity_Subtract_float(_SceneDepth_3475ECEB_Out_1, _Subtract_33AD8FCC_Out_2, _Subtract_F8C04A4A_Out_2);
                float _Property_6925EAED_Out_0 = _FadeDepth;
                float _Divide_1AD2400A_Out_2;
                Unity_Divide_float(_Subtract_F8C04A4A_Out_2, _Property_6925EAED_Out_0, _Divide_1AD2400A_Out_2);
                float _Saturate_DCBD955D_Out_1;
                Unity_Saturate_float(_Divide_1AD2400A_Out_2, _Saturate_DCBD955D_Out_1);
                surface.Alpha = _Saturate_DCBD955D_Out_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =           input.normalOS;
                output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =          input.tangentOS;
                output.ObjectSpacePosition =         input.positionOS;
                output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                output.TimeParameters =              _TimeParameters.xyz;
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
                output.WorldSpacePosition =          input.positionWS;
                output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
            ENDHLSL
        }
        
        Pass
        {
            Name "DepthOnly"
            Tags 
            { 
                "LightMode" = "DepthOnly"
            }
           
            // Render State
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            Cull Off
            ZTest LEqual
            ZWrite On
            ColorMask 0
            
        
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            // Pragmas
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma multi_compile_instancing
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS 
            #define FEATURES_GRAPH_VERTEX
            #define SHADERPASS_DEPTHONLY
            #define REQUIRE_DEPTH_TEXTURE
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.shadergraph/ShaderGraphLibrary/ShaderVariablesFunctions.hlsl"
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _ProjectionRotation;
            float _NoiseScale;
            float _CloudSpeed;
            float _CloudHeight;
            float4 _NoiseRemap;
            float4 _ValleyColor;
            float4 _PeakColor;
            float _PeakSmooth;
            float _ValleySmooth;
            float _NoisePower;
            float _BaseScale;
            float _BaseSpeed;
            float _BaseStrength;
            float _EmissionStrength;
            float _CurvatureRadius;
            float _FresnelPower;
            float _FresnelOpacity;
            float _FadeDepth;
            CBUFFER_END
        
            // Graph Functions
            
            void Unity_Distance_float3(float3 A, float3 B, out float Out)
            {
                Out = distance(A, B);
            }
            
            void Unity_Divide_float(float A, float B, out float Out)
            {
                Out = A / B;
            }
            
            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }
            
            void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }
            
            void Unity_Rotate_About_Axis_Degrees_float(float3 In, float3 Axis, float Rotation, out float3 Out)
            {
                Rotation = radians(Rotation);
            
                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;
                
                Axis = normalize(Axis);
            
                float3x3 rot_mat = { one_minus_c * Axis.x * Axis.x + c,            one_minus_c * Axis.x * Axis.y - Axis.z * s,     one_minus_c * Axis.z * Axis.x + Axis.y * s,
                                          one_minus_c * Axis.x * Axis.y + Axis.z * s,   one_minus_c * Axis.y * Axis.y + c,              one_minus_c * Axis.y * Axis.z - Axis.x * s,
                                          one_minus_c * Axis.z * Axis.x - Axis.y * s,   one_minus_c * Axis.y * Axis.z + Axis.x * s,     one_minus_c * Axis.z * Axis.z + c
                                        };
            
                Out = mul(rot_mat,  In);
            }
            
            void Unity_Multiply_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
            
            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }
            
            
            float2 Unity_GradientNoise_Dir_float(float2 p)
            {
                // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }
            
            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            { 
                float2 p = UV * Scale;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void Unity_Saturate_float(float In, out float Out)
            {
                Out = saturate(In);
            }
            
            void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
            {
                RGBA = float4(R, G, B, A);
                RGB = float3(R, G, B);
                RG = float2(R, G);
            }
            
            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }
            
            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }
            
            void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }
            
            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }
            
            void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
            {
                Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
            }
            
            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }
        
            // Graph Vertex
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 WorldSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
                float3 WorldSpacePosition;
                float3 TimeParameters;
            };
            
            struct VertexDescription
            {
                float3 VertexPosition;
                float3 VertexNormal;
                float3 VertexTangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                float _Distance_9FA356F2_Out_2;
                Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, IN.WorldSpacePosition, _Distance_9FA356F2_Out_2);
                float _Property_FFEF3624_Out_0 = _CurvatureRadius;
                float _Divide_546B609_Out_2;
                Unity_Divide_float(_Distance_9FA356F2_Out_2, _Property_FFEF3624_Out_0, _Divide_546B609_Out_2);
                float _Power_F12EFF02_Out_2;
                Unity_Power_float(_Distance_9FA356F2_Out_2, _Divide_546B609_Out_2, _Power_F12EFF02_Out_2);
                float3 _Multiply_CBE251EB_Out_2;
                Unity_Multiply_float(IN.WorldSpaceNormal, (_Power_F12EFF02_Out_2.xxx), _Multiply_CBE251EB_Out_2);
                float _Property_345ACFDB_Out_0 = _PeakSmooth;
                float _Property_2C7843EC_Out_0 = _ValleySmooth;
                float4 _Property_9F876CEA_Out_0 = _ProjectionRotation;
                float _Split_2A508F07_R_1 = _Property_9F876CEA_Out_0[0];
                float _Split_2A508F07_G_2 = _Property_9F876CEA_Out_0[1];
                float _Split_2A508F07_B_3 = _Property_9F876CEA_Out_0[2];
                float _Split_2A508F07_A_4 = _Property_9F876CEA_Out_0[3];
                float3 _RotateAboutAxis_65218D77_Out_3;
                Unity_Rotate_About_Axis_Degrees_float(IN.WorldSpacePosition, (_Property_9F876CEA_Out_0.xyz), _Split_2A508F07_A_4, _RotateAboutAxis_65218D77_Out_3);
                float _Property_265400EA_Out_0 = _CloudSpeed;
                float _Multiply_68505AAE_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_265400EA_Out_0, _Multiply_68505AAE_Out_2);
                float2 _TilingAndOffset_466B1C44_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_68505AAE_Out_2.xx), _TilingAndOffset_466B1C44_Out_3);
                float _Property_F3DD64DA_Out_0 = _NoiseScale;
                float _GradientNoise_2C184089_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_466B1C44_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_2C184089_Out_2);
                float2 _TilingAndOffset_BB452560_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), float2 (0, 0), _TilingAndOffset_BB452560_Out_3);
                float _GradientNoise_35CCE017_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_BB452560_Out_3, _Property_F3DD64DA_Out_0, _GradientNoise_35CCE017_Out_2);
                float _Add_5B6CBFA1_Out_2;
                Unity_Add_float(_GradientNoise_2C184089_Out_2, _GradientNoise_35CCE017_Out_2, _Add_5B6CBFA1_Out_2);
                float _Divide_B48CBC03_Out_2;
                Unity_Divide_float(_Add_5B6CBFA1_Out_2, 2, _Divide_B48CBC03_Out_2);
                float _Saturate_DE8CD7FB_Out_1;
                Unity_Saturate_float(_Divide_B48CBC03_Out_2, _Saturate_DE8CD7FB_Out_1);
                float _Property_6ADFA1CC_Out_0 = _NoisePower;
                float _Power_B60CE997_Out_2;
                Unity_Power_float(_Saturate_DE8CD7FB_Out_1, _Property_6ADFA1CC_Out_0, _Power_B60CE997_Out_2);
                float4 _Property_58330B6_Out_0 = _NoiseRemap;
                float _Split_AF742FBB_R_1 = _Property_58330B6_Out_0[0];
                float _Split_AF742FBB_G_2 = _Property_58330B6_Out_0[1];
                float _Split_AF742FBB_B_3 = _Property_58330B6_Out_0[2];
                float _Split_AF742FBB_A_4 = _Property_58330B6_Out_0[3];
                float4 _Combine_695E1C91_RGBA_4;
                float3 _Combine_695E1C91_RGB_5;
                float2 _Combine_695E1C91_RG_6;
                Unity_Combine_float(_Split_AF742FBB_R_1, _Split_AF742FBB_G_2, 0, 0, _Combine_695E1C91_RGBA_4, _Combine_695E1C91_RGB_5, _Combine_695E1C91_RG_6);
                float4 _Combine_76EBDC49_RGBA_4;
                float3 _Combine_76EBDC49_RGB_5;
                float2 _Combine_76EBDC49_RG_6;
                Unity_Combine_float(_Split_AF742FBB_B_3, _Split_AF742FBB_A_4, 0, 0, _Combine_76EBDC49_RGBA_4, _Combine_76EBDC49_RGB_5, _Combine_76EBDC49_RG_6);
                float _Remap_BDA469EE_Out_3;
                Unity_Remap_float(_Power_B60CE997_Out_2, _Combine_695E1C91_RG_6, _Combine_76EBDC49_RG_6, _Remap_BDA469EE_Out_3);
                float _Absolute_E40EC47E_Out_1;
                Unity_Absolute_float(_Remap_BDA469EE_Out_3, _Absolute_E40EC47E_Out_1);
                float _Smoothstep_D1147D2C_Out_3;
                Unity_Smoothstep_float(_Property_345ACFDB_Out_0, _Property_2C7843EC_Out_0, _Absolute_E40EC47E_Out_1, _Smoothstep_D1147D2C_Out_3);
                float _Property_DF15A01D_Out_0 = _BaseSpeed;
                float _Multiply_EBF2B910_Out_2;
                Unity_Multiply_float(IN.TimeParameters.x, _Property_DF15A01D_Out_0, _Multiply_EBF2B910_Out_2);
                float2 _TilingAndOffset_93B5B078_Out_3;
                Unity_TilingAndOffset_float((_RotateAboutAxis_65218D77_Out_3.xy), float2 (1, 1), (_Multiply_EBF2B910_Out_2.xx), _TilingAndOffset_93B5B078_Out_3);
                float _Property_33C67278_Out_0 = _BaseScale;
                float _GradientNoise_4F44AE48_Out_2;
                Unity_GradientNoise_float(_TilingAndOffset_93B5B078_Out_3, _Property_33C67278_Out_0, _GradientNoise_4F44AE48_Out_2);
                float _Property_83351417_Out_0 = _BaseStrength;
                float _Multiply_71765D64_Out_2;
                Unity_Multiply_float(_GradientNoise_4F44AE48_Out_2, _Property_83351417_Out_0, _Multiply_71765D64_Out_2);
                float _Add_7ACD772F_Out_2;
                Unity_Add_float(_Smoothstep_D1147D2C_Out_3, _Multiply_71765D64_Out_2, _Add_7ACD772F_Out_2);
                float _Add_E06E68EA_Out_2;
                Unity_Add_float(1, _Property_83351417_Out_0, _Add_E06E68EA_Out_2);
                float _Divide_7F230043_Out_2;
                Unity_Divide_float(_Add_7ACD772F_Out_2, _Add_E06E68EA_Out_2, _Divide_7F230043_Out_2);
                float3 _Multiply_484E11C9_Out_2;
                Unity_Multiply_float(IN.ObjectSpaceNormal, (_Divide_7F230043_Out_2.xxx), _Multiply_484E11C9_Out_2);
                float _Property_5333B30F_Out_0 = _CloudHeight;
                float3 _Multiply_39CA1DCA_Out_2;
                Unity_Multiply_float(_Multiply_484E11C9_Out_2, (_Property_5333B30F_Out_0.xxx), _Multiply_39CA1DCA_Out_2);
                float3 _Add_F738762A_Out_2;
                Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_39CA1DCA_Out_2, _Add_F738762A_Out_2);
                float3 _Add_715D9DD7_Out_2;
                Unity_Add_float3(_Multiply_CBE251EB_Out_2, _Add_F738762A_Out_2, _Add_715D9DD7_Out_2);
                description.VertexPosition = _Add_715D9DD7_Out_2;
                description.VertexNormal = IN.ObjectSpaceNormal;
                description.VertexTangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Graph Pixel
            struct SurfaceDescriptionInputs
            {
                float3 WorldSpacePosition;
                float4 ScreenPosition;
            };
            
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _SceneDepth_3475ECEB_Out_1;
                Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3475ECEB_Out_1);
                float4 _ScreenPosition_7B8291C2_Out_0 = IN.ScreenPosition;
                float _Split_CA18A3D4_R_1 = _ScreenPosition_7B8291C2_Out_0[0];
                float _Split_CA18A3D4_G_2 = _ScreenPosition_7B8291C2_Out_0[1];
                float _Split_CA18A3D4_B_3 = _ScreenPosition_7B8291C2_Out_0[2];
                float _Split_CA18A3D4_A_4 = _ScreenPosition_7B8291C2_Out_0[3];
                float _Subtract_33AD8FCC_Out_2;
                Unity_Subtract_float(_Split_CA18A3D4_A_4, 1, _Subtract_33AD8FCC_Out_2);
                float _Subtract_F8C04A4A_Out_2;
                Unity_Subtract_float(_SceneDepth_3475ECEB_Out_1, _Subtract_33AD8FCC_Out_2, _Subtract_F8C04A4A_Out_2);
                float _Property_6925EAED_Out_0 = _FadeDepth;
                float _Divide_1AD2400A_Out_2;
                Unity_Divide_float(_Subtract_F8C04A4A_Out_2, _Property_6925EAED_Out_0, _Divide_1AD2400A_Out_2);
                float _Saturate_DCBD955D_Out_1;
                Unity_Saturate_float(_Divide_1AD2400A_Out_2, _Saturate_DCBD955D_Out_1);
                surface.Alpha = _Saturate_DCBD955D_Out_1;
                surface.AlphaClipThreshold = 0;
                return surface;
            }
        
            // --------------------------------------------------
            // Structs and Packing
        
            // Generated Type: Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
        
            // Generated Type: Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Generated Type: PackedVaryings
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                float3 interp00 : TEXCOORD0;
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            // Packed Type: Varyings
            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output = (PackedVaryings)0;
                output.positionCS = input.positionCS;
                output.interp00.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            // Unpacked Type: Varyings
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp00.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
        
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =           input.normalOS;
                output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
                output.ObjectSpaceTangent =          input.tangentOS;
                output.ObjectSpacePosition =         input.positionOS;
                output.WorldSpacePosition =          TransformObjectToWorld(input.positionOS);
                output.TimeParameters =              _TimeParameters.xyz;
            
                return output;
            }
            
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            
            
            
            
                output.WorldSpacePosition =          input.positionWS;
                output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                return output;
            }
            
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
            ENDHLSL
        }
        
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}
