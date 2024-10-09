Shader "Neko Legends/Stylized Splash"
{
    Properties
    {
        _Color("Color", Color) = (0, 0, 0, 0)
        _Scale("Scale", Range(0, 100)) = 10
        _Thickness("Thickness", Range(0, 1)) = 0.5
        _NoiseStrength("NoiseStrength", Range(0, 2)) = 0.5
        [NoScaleOffset]_MainTex("_MainTex", 2D) = "white" {}
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue" = "Transparent"
            "DisableBatching" = "False"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalUnlitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
            // LightMode: <None>
        }

        // Render State
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag

        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        // GraphKeywords: <None>

        // Defines

        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1


        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 color : COLOR;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float4 color;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
             float4 VertexColor;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 color : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

        PackedVaryings PackVaryings(Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.color.xyzw = input.color;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

        Varyings UnpackVaryings(PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.color = input.color.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }


        // --------------------------------------------------
        // Graph

        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float _Scale;
        float _Thickness;
        float _NoiseStrength;
        float4 _MainTex_TexelSize;
        float4 _Color;
        CBUFFER_END


            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            // Graph Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif

            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif

            // Graph Functions

            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }

            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
            {
                Out = UV * Tiling + Offset;
            }

            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
            {
                float x; Hash_LegacyMod_2_1_float(p, x);
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
            {
                float2 p = UV * Scale.xy;
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }

            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };

            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }

            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif

            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                UnityTexture2D _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                float _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, -0.5, _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float);
                float2 _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_87a01f19a4b94984923845069259c714_Out_2_Float.xx), _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2);
                float _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float;
                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, 10, _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float);
                float _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float = _NoiseStrength;
                float _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float;
                Unity_Multiply_float_float(_GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float, _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float, _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float);
                float2 _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float.xx), _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2);
                float4 _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.tex, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.samplerstate, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2));
                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_R_4_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.r;
                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_G_5_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.g;
                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_B_6_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.b;
                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.a;
                float4 _Property_bcfdd1f8cdd24657a8ac1ba4b7a5174b_Out_0_Vector4 = _Color;
                float4 _Multiply_a35e8aea97a740169573b5561203ebff_Out_2_Vector4;
                Unity_Multiply_float4_float4(_SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4, _Property_bcfdd1f8cdd24657a8ac1ba4b7a5174b_Out_0_Vector4, _Multiply_a35e8aea97a740169573b5561203ebff_Out_2_Vector4);
                float _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float = _Scale;
                float _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float;
                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float, _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float);
                float _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float = _Thickness;
                float _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float;
                Unity_Step_float(_GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float, _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float, _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float);
                float _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float;
                Unity_Multiply_float_float(_Step_321660fab4494db18d080a964ea85c4b_Out_2_Float, _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float, _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float);
                float _Split_a220be3949e04da7b5004394335d040a_R_1_Float = IN.VertexColor[0];
                float _Split_a220be3949e04da7b5004394335d040a_G_2_Float = IN.VertexColor[1];
                float _Split_a220be3949e04da7b5004394335d040a_B_3_Float = IN.VertexColor[2];
                float _Split_a220be3949e04da7b5004394335d040a_A_4_Float = IN.VertexColor[3];
                float _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                Unity_Multiply_float_float(_Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float, _Split_a220be3949e04da7b5004394335d040a_A_4_Float, _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float);
                surface.BaseColor = (_Multiply_a35e8aea97a740169573b5561203ebff_Out_2_Vector4.xyz);
                surface.Alpha = _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                return surface;
            }

            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                output.ObjectSpaceNormal = input.normalOS;
                output.ObjectSpaceTangent = input.tangentOS.xyz;
                output.ObjectSpacePosition = input.positionOS;

                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            #ifdef HAVE_VFX_MODIFICATION
            #if VFX_USE_GRAPH_VALUES
                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
            #endif
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

            #endif








                #if UNITY_UV_STARTS_AT_TOP
                #else
                #endif


                output.uv0 = input.texCoord0;
                output.VertexColor = input.color;
                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "DepthNormalsOnly"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }

                // Render State
                Cull Back
                ZTest LEqual
                ZWrite On

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 2.0
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag

                // Keywords
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>

                // Defines

                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_COLOR
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_COLOR
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define _SURFACE_TYPE_TRANSPARENT 1


                // custom interpolator pre-include
                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                // Includes
                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                // --------------------------------------------------
                // Structs and Packing

                // custom interpolators pre packing
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                struct Attributes
                {
                     float3 positionOS : POSITION;
                     float3 normalOS : NORMAL;
                     float4 tangentOS : TANGENT;
                     float4 uv0 : TEXCOORD0;
                     float4 color : COLOR;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 normalWS;
                     float4 texCoord0;
                     float4 color;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                     float4 uv0;
                     float4 VertexColor;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                     float4 texCoord0 : INTERP0;
                     float4 color : INTERP1;
                     float3 normalWS : INTERP2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };

                PackedVaryings PackVaryings(Varyings input)
                {
                    PackedVaryings output;
                    ZERO_INITIALIZE(PackedVaryings, output);
                    output.positionCS = input.positionCS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.color.xyzw = input.color;
                    output.normalWS.xyz = input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }

                Varyings UnpackVaryings(PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.color = input.color.xyzw;
                    output.normalWS = input.normalWS.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }


                // --------------------------------------------------
                // Graph

                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _Scale;
                float _Thickness;
                float _NoiseStrength;
                float4 _MainTex_TexelSize;
                float4 _Color;
                CBUFFER_END


                    // Object and Global properties
                    SAMPLER(SamplerState_Linear_Repeat);
                    TEXTURE2D(_MainTex);
                    SAMPLER(sampler_MainTex);

                    // Graph Includes
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                    // -- Property used by ScenePickingPass
                    #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                    #endif

                    // -- Properties used by SceneSelectionPass
                    #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                    #endif

                    // Graph Functions

                    void Unity_Multiply_float_float(float A, float B, out float Out)
                    {
                        Out = A * B;
                    }

                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                    {
                        Out = UV * Tiling + Offset;
                    }

                    float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                    {
                        float x; Hash_LegacyMod_2_1_float(p, x);
                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                    }

                    void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                    {
                        float2 p = UV * Scale.xy;
                        float2 ip = floor(p);
                        float2 fp = frac(p);
                        float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                        float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                        float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                        float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                    }

                    void Unity_Step_float(float Edge, float In, out float Out)
                    {
                        Out = step(Edge, In);
                    }

                    // Custom interpolators pre vertex
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                    // Graph Vertex
                    struct VertexDescription
                    {
                        float3 Position;
                        float3 Normal;
                        float3 Tangent;
                    };

                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                    {
                        VertexDescription description = (VertexDescription)0;
                        description.Position = IN.ObjectSpacePosition;
                        description.Normal = IN.ObjectSpaceNormal;
                        description.Tangent = IN.ObjectSpaceTangent;
                        return description;
                    }

                    // Custom interpolators, pre surface
                    #ifdef FEATURES_GRAPH_VERTEX
                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                    {
                    return output;
                    }
                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                    #endif

                    // Graph Pixel
                    struct SurfaceDescription
                    {
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, -0.5, _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float);
                        float2 _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_87a01f19a4b94984923845069259c714_Out_2_Float.xx), _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2);
                        float _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float = _Scale;
                        float _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float;
                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float, _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float);
                        float _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float = _Thickness;
                        float _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float;
                        Unity_Step_float(_GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float, _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float, _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float);
                        UnityTexture2D _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                        float _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float;
                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, 10, _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float);
                        float _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float = _NoiseStrength;
                        float _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float;
                        Unity_Multiply_float_float(_GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float, _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float, _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float);
                        float2 _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float.xx), _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2);
                        float4 _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.tex, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.samplerstate, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2));
                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_R_4_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.r;
                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_G_5_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.g;
                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_B_6_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.b;
                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.a;
                        float _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float;
                        Unity_Multiply_float_float(_Step_321660fab4494db18d080a964ea85c4b_Out_2_Float, _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float, _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float);
                        float _Split_a220be3949e04da7b5004394335d040a_R_1_Float = IN.VertexColor[0];
                        float _Split_a220be3949e04da7b5004394335d040a_G_2_Float = IN.VertexColor[1];
                        float _Split_a220be3949e04da7b5004394335d040a_B_3_Float = IN.VertexColor[2];
                        float _Split_a220be3949e04da7b5004394335d040a_A_4_Float = IN.VertexColor[3];
                        float _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                        Unity_Multiply_float_float(_Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float, _Split_a220be3949e04da7b5004394335d040a_A_4_Float, _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float);
                        surface.Alpha = _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                        return surface;
                    }

                    // --------------------------------------------------
                    // Build Graph Inputs
                    #ifdef HAVE_VFX_MODIFICATION
                    #define VFX_SRP_ATTRIBUTES Attributes
                    #define VFX_SRP_VARYINGS Varyings
                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                    #endif
                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                    {
                        VertexDescriptionInputs output;
                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                        output.ObjectSpaceNormal = input.normalOS;
                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                        output.ObjectSpacePosition = input.positionOS;

                        return output;
                    }
                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                    {
                        SurfaceDescriptionInputs output;
                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                    #ifdef HAVE_VFX_MODIFICATION
                    #if VFX_USE_GRAPH_VALUES
                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                    #endif
                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                    #endif








                        #if UNITY_UV_STARTS_AT_TOP
                        #else
                        #endif


                        output.uv0 = input.texCoord0;
                        output.VertexColor = input.color;
                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                    // --------------------------------------------------
                    // Visual Effect Vertex Invocations
                    #ifdef HAVE_VFX_MODIFICATION
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                    #endif

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
                        Cull Back
                        ZTest LEqual
                        ZWrite On
                        ColorMask 0

                        // Debug
                        // <None>

                        // --------------------------------------------------
                        // Pass

                        HLSLPROGRAM

                        // Pragmas
                        #pragma target 2.0
                        #pragma multi_compile_instancing
                        #pragma vertex vert
                        #pragma fragment frag

                        // Keywords
                        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                        // GraphKeywords: <None>

                        // Defines

                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define ATTRIBUTES_NEED_COLOR
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TEXCOORD0
                        #define VARYINGS_NEED_COLOR
                        #define FEATURES_GRAPH_VERTEX
                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                        #define SHADERPASS SHADERPASS_SHADOWCASTER


                        // custom interpolator pre-include
                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                        // Includes
                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                        // --------------------------------------------------
                        // Structs and Packing

                        // custom interpolators pre packing
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                        struct Attributes
                        {
                             float3 positionOS : POSITION;
                             float3 normalOS : NORMAL;
                             float4 tangentOS : TANGENT;
                             float4 uv0 : TEXCOORD0;
                             float4 color : COLOR;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : INSTANCEID_SEMANTIC;
                            #endif
                        };
                        struct Varyings
                        {
                             float4 positionCS : SV_POSITION;
                             float3 normalWS;
                             float4 texCoord0;
                             float4 color;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };
                        struct SurfaceDescriptionInputs
                        {
                             float4 uv0;
                             float4 VertexColor;
                             float3 TimeParameters;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float4 texCoord0 : INTERP0;
                             float4 color : INTERP1;
                             float3 normalWS : INTERP2;
                            #if UNITY_ANY_INSTANCING_ENABLED
                             uint instanceID : CUSTOM_INSTANCE_ID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                            #endif
                        };

                        PackedVaryings PackVaryings(Varyings input)
                        {
                            PackedVaryings output;
                            ZERO_INITIALIZE(PackedVaryings, output);
                            output.positionCS = input.positionCS;
                            output.texCoord0.xyzw = input.texCoord0;
                            output.color.xyzw = input.color;
                            output.normalWS.xyz = input.normalWS;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }

                        Varyings UnpackVaryings(PackedVaryings input)
                        {
                            Varyings output;
                            output.positionCS = input.positionCS;
                            output.texCoord0 = input.texCoord0.xyzw;
                            output.color = input.color.xyzw;
                            output.normalWS = input.normalWS.xyz;
                            #if UNITY_ANY_INSTANCING_ENABLED
                            output.instanceID = input.instanceID;
                            #endif
                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                            #endif
                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                            #endif
                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                            output.cullFace = input.cullFace;
                            #endif
                            return output;
                        }


                        // --------------------------------------------------
                        // Graph

                        // Graph Properties
                        CBUFFER_START(UnityPerMaterial)
                        float _Scale;
                        float _Thickness;
                        float _NoiseStrength;
                        float4 _MainTex_TexelSize;
                        float4 _Color;
                        CBUFFER_END


                            // Object and Global properties
                            SAMPLER(SamplerState_Linear_Repeat);
                            TEXTURE2D(_MainTex);
                            SAMPLER(sampler_MainTex);

                            // Graph Includes
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                            // -- Property used by ScenePickingPass
                            #ifdef SCENEPICKINGPASS
                            float4 _SelectionID;
                            #endif

                            // -- Properties used by SceneSelectionPass
                            #ifdef SCENESELECTIONPASS
                            int _ObjectId;
                            int _PassValue;
                            #endif

                            // Graph Functions

                            void Unity_Multiply_float_float(float A, float B, out float Out)
                            {
                                Out = A * B;
                            }

                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                            {
                                Out = UV * Tiling + Offset;
                            }

                            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                            {
                                float x; Hash_LegacyMod_2_1_float(p, x);
                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                            }

                            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                            {
                                float2 p = UV * Scale.xy;
                                float2 ip = floor(p);
                                float2 fp = frac(p);
                                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                            }

                            void Unity_Step_float(float Edge, float In, out float Out)
                            {
                                Out = step(Edge, In);
                            }

                            // Custom interpolators pre vertex
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                            // Graph Vertex
                            struct VertexDescription
                            {
                                float3 Position;
                                float3 Normal;
                                float3 Tangent;
                            };

                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                            {
                                VertexDescription description = (VertexDescription)0;
                                description.Position = IN.ObjectSpacePosition;
                                description.Normal = IN.ObjectSpaceNormal;
                                description.Tangent = IN.ObjectSpaceTangent;
                                return description;
                            }

                            // Custom interpolators, pre surface
                            #ifdef FEATURES_GRAPH_VERTEX
                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                            {
                            return output;
                            }
                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                            #endif

                            // Graph Pixel
                            struct SurfaceDescription
                            {
                                float Alpha;
                            };

                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                            {
                                SurfaceDescription surface = (SurfaceDescription)0;
                                float _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float;
                                Unity_Multiply_float_float(IN.TimeParameters.x, -0.5, _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float);
                                float2 _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_87a01f19a4b94984923845069259c714_Out_2_Float.xx), _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2);
                                float _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float = _Scale;
                                float _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float;
                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float, _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float);
                                float _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float = _Thickness;
                                float _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float;
                                Unity_Step_float(_GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float, _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float, _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float);
                                UnityTexture2D _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                                float _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float;
                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, 10, _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float);
                                float _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float = _NoiseStrength;
                                float _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float;
                                Unity_Multiply_float_float(_GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float, _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float, _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float);
                                float2 _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float.xx), _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2);
                                float4 _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.tex, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.samplerstate, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2));
                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_R_4_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.r;
                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_G_5_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.g;
                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_B_6_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.b;
                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.a;
                                float _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float;
                                Unity_Multiply_float_float(_Step_321660fab4494db18d080a964ea85c4b_Out_2_Float, _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float, _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float);
                                float _Split_a220be3949e04da7b5004394335d040a_R_1_Float = IN.VertexColor[0];
                                float _Split_a220be3949e04da7b5004394335d040a_G_2_Float = IN.VertexColor[1];
                                float _Split_a220be3949e04da7b5004394335d040a_B_3_Float = IN.VertexColor[2];
                                float _Split_a220be3949e04da7b5004394335d040a_A_4_Float = IN.VertexColor[3];
                                float _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                                Unity_Multiply_float_float(_Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float, _Split_a220be3949e04da7b5004394335d040a_A_4_Float, _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float);
                                surface.Alpha = _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                                return surface;
                            }

                            // --------------------------------------------------
                            // Build Graph Inputs
                            #ifdef HAVE_VFX_MODIFICATION
                            #define VFX_SRP_ATTRIBUTES Attributes
                            #define VFX_SRP_VARYINGS Varyings
                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                            #endif
                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                            {
                                VertexDescriptionInputs output;
                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                output.ObjectSpaceNormal = input.normalOS;
                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                output.ObjectSpacePosition = input.positionOS;

                                return output;
                            }
                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                            {
                                SurfaceDescriptionInputs output;
                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                            #ifdef HAVE_VFX_MODIFICATION
                            #if VFX_USE_GRAPH_VALUES
                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                            #endif
                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                            #endif








                                #if UNITY_UV_STARTS_AT_TOP
                                #else
                                #endif


                                output.uv0 = input.texCoord0;
                                output.VertexColor = input.color;
                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

                            // --------------------------------------------------
                            // Visual Effect Vertex Invocations
                            #ifdef HAVE_VFX_MODIFICATION
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                            #endif

                            ENDHLSL
                            }
                            Pass
                            {
                                Name "SceneSelectionPass"
                                Tags
                                {
                                    "LightMode" = "SceneSelectionPass"
                                }

                                // Render State
                                Cull Off

                                // Debug
                                // <None>

                                // --------------------------------------------------
                                // Pass

                                HLSLPROGRAM

                                // Pragmas
                                #pragma target 2.0
                                #pragma vertex vert
                                #pragma fragment frag

                                // Keywords
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define ATTRIBUTES_NEED_COLOR
                                #define VARYINGS_NEED_TEXCOORD0
                                #define VARYINGS_NEED_COLOR
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHONLY
                                #define SCENESELECTIONPASS 1
                                #define ALPHA_CLIP_THRESHOLD 1


                                // custom interpolator pre-include
                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                // Includes
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                // --------------------------------------------------
                                // Structs and Packing

                                // custom interpolators pre packing
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                struct Attributes
                                {
                                     float3 positionOS : POSITION;
                                     float3 normalOS : NORMAL;
                                     float4 tangentOS : TANGENT;
                                     float4 uv0 : TEXCOORD0;
                                     float4 color : COLOR;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float4 texCoord0;
                                     float4 color;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };
                                struct SurfaceDescriptionInputs
                                {
                                     float4 uv0;
                                     float4 VertexColor;
                                     float3 TimeParameters;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float4 texCoord0 : INTERP0;
                                     float4 color : INTERP1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : CUSTOM_INSTANCE_ID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                    #endif
                                };

                                PackedVaryings PackVaryings(Varyings input)
                                {
                                    PackedVaryings output;
                                    ZERO_INITIALIZE(PackedVaryings, output);
                                    output.positionCS = input.positionCS;
                                    output.texCoord0.xyzw = input.texCoord0;
                                    output.color.xyzw = input.color;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }

                                Varyings UnpackVaryings(PackedVaryings input)
                                {
                                    Varyings output;
                                    output.positionCS = input.positionCS;
                                    output.texCoord0 = input.texCoord0.xyzw;
                                    output.color = input.color.xyzw;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    output.instanceID = input.instanceID;
                                    #endif
                                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                    #endif
                                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                    #endif
                                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                    output.cullFace = input.cullFace;
                                    #endif
                                    return output;
                                }


                                // --------------------------------------------------
                                // Graph

                                // Graph Properties
                                CBUFFER_START(UnityPerMaterial)
                                float _Scale;
                                float _Thickness;
                                float _NoiseStrength;
                                float4 _MainTex_TexelSize;
                                float4 _Color;
                                CBUFFER_END


                                    // Object and Global properties
                                    SAMPLER(SamplerState_Linear_Repeat);
                                    TEXTURE2D(_MainTex);
                                    SAMPLER(sampler_MainTex);

                                    // Graph Includes
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                    // -- Property used by ScenePickingPass
                                    #ifdef SCENEPICKINGPASS
                                    float4 _SelectionID;
                                    #endif

                                    // -- Properties used by SceneSelectionPass
                                    #ifdef SCENESELECTIONPASS
                                    int _ObjectId;
                                    int _PassValue;
                                    #endif

                                    // Graph Functions

                                    void Unity_Multiply_float_float(float A, float B, out float Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                    {
                                        Out = UV * Tiling + Offset;
                                    }

                                    float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                    {
                                        float x; Hash_LegacyMod_2_1_float(p, x);
                                        return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                    }

                                    void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                    {
                                        float2 p = UV * Scale.xy;
                                        float2 ip = floor(p);
                                        float2 fp = frac(p);
                                        float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                        float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                        float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                        float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                        fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                        Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                    }

                                    void Unity_Step_float(float Edge, float In, out float Out)
                                    {
                                        Out = step(Edge, In);
                                    }

                                    // Custom interpolators pre vertex
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                    // Graph Vertex
                                    struct VertexDescription
                                    {
                                        float3 Position;
                                        float3 Normal;
                                        float3 Tangent;
                                    };

                                    VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                    {
                                        VertexDescription description = (VertexDescription)0;
                                        description.Position = IN.ObjectSpacePosition;
                                        description.Normal = IN.ObjectSpaceNormal;
                                        description.Tangent = IN.ObjectSpaceTangent;
                                        return description;
                                    }

                                    // Custom interpolators, pre surface
                                    #ifdef FEATURES_GRAPH_VERTEX
                                    Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                    {
                                    return output;
                                    }
                                    #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                    #endif

                                    // Graph Pixel
                                    struct SurfaceDescription
                                    {
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, -0.5, _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float);
                                        float2 _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_87a01f19a4b94984923845069259c714_Out_2_Float.xx), _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2);
                                        float _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float = _Scale;
                                        float _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float;
                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float, _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float);
                                        float _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float = _Thickness;
                                        float _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float;
                                        Unity_Step_float(_GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float, _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float, _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float);
                                        UnityTexture2D _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                                        float _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float;
                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, 10, _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float);
                                        float _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float = _NoiseStrength;
                                        float _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float;
                                        Unity_Multiply_float_float(_GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float, _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float, _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float);
                                        float2 _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float.xx), _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2);
                                        float4 _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.tex, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.samplerstate, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2));
                                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_R_4_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.r;
                                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_G_5_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.g;
                                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_B_6_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.b;
                                        float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.a;
                                        float _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float;
                                        Unity_Multiply_float_float(_Step_321660fab4494db18d080a964ea85c4b_Out_2_Float, _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float, _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float);
                                        float _Split_a220be3949e04da7b5004394335d040a_R_1_Float = IN.VertexColor[0];
                                        float _Split_a220be3949e04da7b5004394335d040a_G_2_Float = IN.VertexColor[1];
                                        float _Split_a220be3949e04da7b5004394335d040a_B_3_Float = IN.VertexColor[2];
                                        float _Split_a220be3949e04da7b5004394335d040a_A_4_Float = IN.VertexColor[3];
                                        float _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                                        Unity_Multiply_float_float(_Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float, _Split_a220be3949e04da7b5004394335d040a_A_4_Float, _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float);
                                        surface.Alpha = _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                                        return surface;
                                    }

                                    // --------------------------------------------------
                                    // Build Graph Inputs
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #define VFX_SRP_ATTRIBUTES Attributes
                                    #define VFX_SRP_VARYINGS Varyings
                                    #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                    #endif
                                    VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                    {
                                        VertexDescriptionInputs output;
                                        ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                        output.ObjectSpaceNormal = input.normalOS;
                                        output.ObjectSpaceTangent = input.tangentOS.xyz;
                                        output.ObjectSpacePosition = input.positionOS;

                                        return output;
                                    }
                                    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                    {
                                        SurfaceDescriptionInputs output;
                                        ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                    #ifdef HAVE_VFX_MODIFICATION
                                    #if VFX_USE_GRAPH_VALUES
                                        uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                        /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                    #endif
                                        /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                    #endif








                                        #if UNITY_UV_STARTS_AT_TOP
                                        #else
                                        #endif


                                        output.uv0 = input.texCoord0;
                                        output.VertexColor = input.color;
                                        output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                    // --------------------------------------------------
                                    // Visual Effect Vertex Invocations
                                    #ifdef HAVE_VFX_MODIFICATION
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                    #endif

                                    ENDHLSL
                                    }
                                    Pass
                                    {
                                        Name "ScenePickingPass"
                                        Tags
                                        {
                                            "LightMode" = "Picking"
                                        }

                                        // Render State
                                        Cull Back

                                        // Debug
                                        // <None>

                                        // --------------------------------------------------
                                        // Pass

                                        HLSLPROGRAM

                                        // Pragmas
                                        #pragma target 2.0
                                        #pragma vertex vert
                                        #pragma fragment frag

                                        // Keywords
                                        // PassKeywords: <None>
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_COLOR
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_COLOR
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_DEPTHONLY
                                        #define SCENEPICKINGPASS 1
                                        #define ALPHA_CLIP_THRESHOLD 1


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

                                        // --------------------------------------------------
                                        // Structs and Packing

                                        // custom interpolators pre packing
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                        struct Attributes
                                        {
                                             float3 positionOS : POSITION;
                                             float3 normalOS : NORMAL;
                                             float4 tangentOS : TANGENT;
                                             float4 uv0 : TEXCOORD0;
                                             float4 color : COLOR;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float4 texCoord0;
                                             float4 color;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };
                                        struct SurfaceDescriptionInputs
                                        {
                                             float4 uv0;
                                             float4 VertexColor;
                                             float3 TimeParameters;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float4 texCoord0 : INTERP0;
                                             float4 color : INTERP1;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : CUSTOM_INSTANCE_ID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                            #endif
                                        };

                                        PackedVaryings PackVaryings(Varyings input)
                                        {
                                            PackedVaryings output;
                                            ZERO_INITIALIZE(PackedVaryings, output);
                                            output.positionCS = input.positionCS;
                                            output.texCoord0.xyzw = input.texCoord0;
                                            output.color.xyzw = input.color;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }

                                        Varyings UnpackVaryings(PackedVaryings input)
                                        {
                                            Varyings output;
                                            output.positionCS = input.positionCS;
                                            output.texCoord0 = input.texCoord0.xyzw;
                                            output.color = input.color.xyzw;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            output.instanceID = input.instanceID;
                                            #endif
                                            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                            #endif
                                            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                            #endif
                                            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                            output.cullFace = input.cullFace;
                                            #endif
                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Graph

                                        // Graph Properties
                                        CBUFFER_START(UnityPerMaterial)
                                        float _Scale;
                                        float _Thickness;
                                        float _NoiseStrength;
                                        float4 _MainTex_TexelSize;
                                        float4 _Color;
                                        CBUFFER_END


                                            // Object and Global properties
                                            SAMPLER(SamplerState_Linear_Repeat);
                                            TEXTURE2D(_MainTex);
                                            SAMPLER(sampler_MainTex);

                                            // Graph Includes
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Hashes.hlsl"

                                            // -- Property used by ScenePickingPass
                                            #ifdef SCENEPICKINGPASS
                                            float4 _SelectionID;
                                            #endif

                                            // -- Properties used by SceneSelectionPass
                                            #ifdef SCENESELECTIONPASS
                                            int _ObjectId;
                                            int _PassValue;
                                            #endif

                                            // Graph Functions

                                            void Unity_Multiply_float_float(float A, float B, out float Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                            {
                                                Out = UV * Tiling + Offset;
                                            }

                                            float2 Unity_GradientNoise_LegacyMod_Dir_float(float2 p)
                                            {
                                                float x; Hash_LegacyMod_2_1_float(p, x);
                                                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                                            }

                                            void Unity_GradientNoise_LegacyMod_float(float2 UV, float3 Scale, out float Out)
                                            {
                                                float2 p = UV * Scale.xy;
                                                float2 ip = floor(p);
                                                float2 fp = frac(p);
                                                float d00 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip), fp);
                                                float d01 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                                                float d10 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                                                float d11 = dot(Unity_GradientNoise_LegacyMod_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                                                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                                                Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                                            }

                                            void Unity_Step_float(float Edge, float In, out float Out)
                                            {
                                                Out = step(Edge, In);
                                            }

                                            // Custom interpolators pre vertex
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                            // Graph Vertex
                                            struct VertexDescription
                                            {
                                                float3 Position;
                                                float3 Normal;
                                                float3 Tangent;
                                            };

                                            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                            {
                                                VertexDescription description = (VertexDescription)0;
                                                description.Position = IN.ObjectSpacePosition;
                                                description.Normal = IN.ObjectSpaceNormal;
                                                description.Tangent = IN.ObjectSpaceTangent;
                                                return description;
                                            }

                                            // Custom interpolators, pre surface
                                            #ifdef FEATURES_GRAPH_VERTEX
                                            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                            {
                                            return output;
                                            }
                                            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                            #endif

                                            // Graph Pixel
                                            struct SurfaceDescription
                                            {
                                                float Alpha;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                float _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, -0.5, _Multiply_87a01f19a4b94984923845069259c714_Out_2_Float);
                                                float2 _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_87a01f19a4b94984923845069259c714_Out_2_Float.xx), _TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2);
                                                float _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float = _Scale;
                                                float _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float;
                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, _Property_a214db4d86644ed0977b0604321a8b55_Out_0_Float, _GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float);
                                                float _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float = _Thickness;
                                                float _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float;
                                                Unity_Step_float(_GradientNoise_8c8135820d0741d580a2284865e7f2f2_Out_2_Float, _Property_bf16526292af47ac936cb06e4e67c3c9_Out_0_Float, _Step_321660fab4494db18d080a964ea85c4b_Out_2_Float);
                                                UnityTexture2D _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_MainTex);
                                                float _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float;
                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_a0da497777ad4837bd141402a173e967_Out_3_Vector2, 10, _GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float);
                                                float _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float = _NoiseStrength;
                                                float _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float;
                                                Unity_Multiply_float_float(_GradientNoise_8373f9abf3aa4ecd8f5d5928c6506b0d_Out_2_Float, _Property_04ab5f92558240db80a7c92ee25c1c3a_Out_0_Float, _Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float);
                                                float2 _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_d3e0017a292e4259b148a599a02bdd5a_Out_2_Float.xx), _TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2);
                                                float4 _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.tex, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.samplerstate, _Property_301aae067114415d8a743a750291c0cc_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_a595bfb2d98642a99bb6053814eeabce_Out_3_Vector2));
                                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_R_4_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.r;
                                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_G_5_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.g;
                                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_B_6_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.b;
                                                float _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float = _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_RGBA_0_Vector4.a;
                                                float _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float;
                                                Unity_Multiply_float_float(_Step_321660fab4494db18d080a964ea85c4b_Out_2_Float, _SampleTexture2D_bbc9130c22d242ecb41f6f757a4736ac_A_7_Float, _Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float);
                                                float _Split_a220be3949e04da7b5004394335d040a_R_1_Float = IN.VertexColor[0];
                                                float _Split_a220be3949e04da7b5004394335d040a_G_2_Float = IN.VertexColor[1];
                                                float _Split_a220be3949e04da7b5004394335d040a_B_3_Float = IN.VertexColor[2];
                                                float _Split_a220be3949e04da7b5004394335d040a_A_4_Float = IN.VertexColor[3];
                                                float _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                                                Unity_Multiply_float_float(_Multiply_f60e805bec344c4494bd207c3f0e97fc_Out_2_Float, _Split_a220be3949e04da7b5004394335d040a_A_4_Float, _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float);
                                                surface.Alpha = _Multiply_38c4bfc5ec564c26855e24bb798ddb29_Out_2_Float;
                                                return surface;
                                            }

                                            // --------------------------------------------------
                                            // Build Graph Inputs
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #define VFX_SRP_ATTRIBUTES Attributes
                                            #define VFX_SRP_VARYINGS Varyings
                                            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
                                            #endif
                                            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                            {
                                                VertexDescriptionInputs output;
                                                ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                output.ObjectSpaceNormal = input.normalOS;
                                                output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                output.ObjectSpacePosition = input.positionOS;

                                                return output;
                                            }
                                            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                            {
                                                SurfaceDescriptionInputs output;
                                                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

                                            #ifdef HAVE_VFX_MODIFICATION
                                            #if VFX_USE_GRAPH_VALUES
                                                uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
                                                /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
                                            #endif
                                                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */

                                            #endif








                                                #if UNITY_UV_STARTS_AT_TOP
                                                #else
                                                #endif


                                                output.uv0 = input.texCoord0;
                                                output.VertexColor = input.color;
                                                output.TimeParameters = _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                                            // --------------------------------------------------
                                            // Visual Effect Vertex Invocations
                                            #ifdef HAVE_VFX_MODIFICATION
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                            #endif

                                            ENDHLSL
                                            }
    }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                CustomEditorForRenderPipeline "NekoLegends.WaterfallStylizedSplashInspector" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                FallBack "Hidden/Shader Graph/FallbackError"
}