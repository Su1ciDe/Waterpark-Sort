Shader "Neko Legends/Waterfall Stylized"
{
    Properties
    {
        [HDR] BaseColor("BaseColor", Color) = (0, 0.1852703, 4, 0)
        _radius("radius", Range(0, 1)) = 0.3
        _upperHalfRadius("upperHalfRadius", Range(0, 5)) = 0.5
        _bottomHalfRadius("bottomHalfRadius", Range(0, 5)) = 0.5
        _watergap("watergap", Range(-5, 1)) = 0.1
        radiusGradient("radiusGradient", Range(0, 1)) = 0.3
        innerFoamRadius("innerFoamRadius", Float) = 0.3
        _flowSpeedDirection("flowSpeedDirection", Range(-5, 5)) = 1
        _flowVariation("flowVariation", Range(-0.25, 0.25)) = 0.1
        [HDR]_shineColor("shineColor", Color) = (0.5833334, 1, 0, 0)
        _shineConcentration("shineConcentration", Range(0, 100)) = 50
        _shineDiminish("shineDiminish", Range(0, 20)) = 3.5
        _shineVerticalOffset("shineVerticalOffset", Range(-5, 5)) = 0.8
        _shineScale("shineScale", Range(0, 500)) = 250
        _shineLength("shineLength", Range(-0.5, 0.5)) = 0.2
        _shineFoamMiddle("shineFoamMiddle", Range(0, 1)) = 0.25
        _shineBottomHeight("shineBottomHeight", Range(0, 100)) = 7.5
        _waveEdgeWobbleSpeed("waveEdgeWobbleSpeed", Range(0, 5)) = 1
        _waveEdgeWobbleAmount("waveEdgeWobbleAmount", Range(0, 20)) = 10
        _waveEdgeWobbleDistance("waveEdgeWobbleDistance", Range(0, 0.03)) = 0.02
        _waveEdgeThickness("waveEdgeThickness", Range(0, 0.5)) = 0.06
        _waveVerticalStrength("waveVerticalStrength", Range(0, 5)) = 1
        _waveSpeed("waveSpeed", Range(-2, 2)) = 0.2
        _waveThickness("waveThickness", Range(0, 50)) = 15
        _waveDistortion("waveDistortion", Range(0, 0.01)) = 0.005
        _waveNoiseScale("waveNoiseScale", Range(0, 50)) = 5
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
            "UniversalMaterialType" = "Lit"
            "Queue" = "Transparent"
            "DisableBatching" = "False"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

        // Render State
        Cull Off
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
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        // GraphKeywords: <None>

        // Defines

        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_WS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define REQUIRE_OPAQUE_TEXTURE


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
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
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
             float3 WorldSpaceNormal;
             float3 WorldSpaceTangent;
             float3 WorldSpaceBiTangent;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
             float4 uv0;
             float3 TimeParameters;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP3;
            #endif
             float4 tangentWS : INTERP4;
             float4 texCoord0 : INTERP5;
             float4 fogFactorAndVertexLight : INTERP6;
             float3 positionWS : INTERP7;
             float3 normalWS : INTERP8;
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
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
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
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
        float radiusGradient;
        float4 BaseColor;
        float innerFoamRadius;
        float _upperHalfRadius;
        float _bottomHalfRadius;
        float _watergap;
        float _flowSpeedDirection;
        float _flowVariation;
        float4 _shineColor;
        float _shineConcentration;
        float _shineDiminish;
        float _shineVerticalOffset;
        float _shineScale;
        float _shineLength;
        float _shineFoamMiddle;
        float _shineBottomHeight;
        float _waveEdgeWobbleSpeed;
        float _waveEdgeWobbleAmount;
        float _waveEdgeWobbleDistance;
        float _waveEdgeThickness;
        float _waveVerticalStrength;
        float _waveSpeed;
        float _waveThickness;
        float _waveDistortion;
        float _waveNoiseScale;
        CBUFFER_END


            // Object and Global properties
            float4 _NekoLegendsWaterfallObjectInteraction;
            float _radius;

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

            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A * B;
            }

            void Unity_Preview_float(float In, out float Out)
            {
                Out = In;
            }

            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }

            void Unity_Sine_float(float In, out float Out)
            {
                Out = sin(In);
            }

            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }

            void Unity_OneMinus_float(float In, out float Out)
            {
                Out = 1 - In;
            }

            void Unity_InvertColors_float(float In, float InvertColors, out float Out)
            {
                Out = abs(InvertColors - In);
            }

            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
            {
                Out = A * B;
            }

            float Unity_SimpleNoise_ValueNoise_LegacySine_float(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0; Hash_LegacySine_2_1_float(c0, r0);
                float r1; Hash_LegacySine_2_1_float(c1, r1);
                float r2; Hash_LegacySine_2_1_float(c2, r2);
                float r3; Hash_LegacySine_2_1_float(c3, r3);
                float bottomOfGrid = lerp(r0, r1, f.x);
                float topOfGrid = lerp(r2, r3, f.x);
                float t = lerp(bottomOfGrid, topOfGrid, f.y);
                return t;
            }

            void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
            {
                float freq, amp;
                Out = 0.0f;
                freq = pow(2.0, float(0));
                amp = pow(0.5, float(3 - 0));
                Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3 - 1));
                Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3 - 2));
                Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
            }

            void Unity_Power_float(float A, float B, out float Out)
            {
                Out = pow(A, B);
            }

            void Unity_Subtract_float(float A, float B, out float Out)
            {
                Out = A - B;
            }

            void Unity_Absolute_float(float In, out float Out)
            {
                Out = abs(In);
            }

            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }

            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A + B;
            }

            void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
            {

                        #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                        #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                        #endif
                float3 worldDerivativeX = ddx(Position);
                float3 worldDerivativeY = ddy(Position);

                float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
                float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
                float d = dot(worldDerivativeX, crossY);
                float sgn = d < 0.0 ? (-1.0f) : 1.0f;
                float surface = sgn / max(0.000000000000001192093f, abs(d));

                float dHdx = ddx(In);
                float dHdy = ddy(In);
                float3 surfGrad = surface * (dHdx * crossY + dHdy * crossX);
                Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
                Out = TransformWorldToTangent(Out, TangentMatrix);
            }

            void Unity_SceneColor_float(float4 UV, out float3 Out)
            {
                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
            }

            void Unity_Blend_Screen_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
            {
                Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                Out = lerp(Base, Out, Opacity);
            }

            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
            {
                Out = A + B;
            }

            void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
            {
                float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                float4 result2 = 2.0 * Base * Blend;
                float4 zeroOrOne = step(Base, 0.5);
                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                Out = lerp(Base, Out, Opacity);
            }

            void Unity_Distance_float3(float3 A, float3 B, out float Out)
            {
                Out = distance(A, B);
            }

            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }

            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = Predicate ? True : False;
            }

            void Unity_Lerp_float(float A, float B, float T, out float Out)
            {
                Out = lerp(A, B, T);
            }

            void Unity_Saturate_float4(float4 In, out float4 Out)
            {
                Out = saturate(In);
            }

            void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
            {
                Out = smoothstep(Edge1, Edge2, In);
            }

            void Unity_OneMinus_float4(float4 In, out float4 Out)
            {
                Out = 1 - In;
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
                float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                float3 NormalWS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
            };

            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_8644a44b0c3a44b0b952c46eb7cf1f70_Out_0_Float = _waveEdgeThickness;
                float _Float_027a96f62a99423392bab3be567316d3_Out_0_Float = _Property_8644a44b0c3a44b0b952c46eb7cf1f70_Out_0_Float;
                float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                float _Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float;
                Unity_Step_float(_Float_027a96f62a99423392bab3be567316d3_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float);
                float _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float;
                Unity_OneMinus_float(_Float_027a96f62a99423392bab3be567316d3_Out_0_Float, _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float);
                float _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float;
                Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float, _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float);
                float _Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float;
                Unity_Multiply_float_float(_Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float, _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float, _Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float);
                float _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float;
                float _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_InvertColors = float(1);
                Unity_InvertColors_float(_Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float, _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_InvertColors, _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float);
                float4 _Property_361bb62208d94436a8592182d9a62718_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_shineColor) : _shineColor;
                float _Property_df930666d03542579f9e2f0617c60c0b_Out_0_Float = _shineFoamMiddle;
                float _Split_6e20ef5497714818850c8192df227845_R_1_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                         length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                         length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[0];
                float _Split_6e20ef5497714818850c8192df227845_G_2_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                         length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                         length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[1];
                float _Split_6e20ef5497714818850c8192df227845_B_3_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                         length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                         length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[2];
                float _Split_6e20ef5497714818850c8192df227845_A_4_Float = 0;
                float2 _Vector2_975b5ab1741c4306b35fd078943f2a9b_Out_0_Vector2 = float2(_Split_6e20ef5497714818850c8192df227845_R_1_Float, _Split_6e20ef5497714818850c8192df227845_B_3_Float);
                float4 _UV_014a305db25448bd996abe2571b3b9f7_Out_0_Vector4 = IN.uv0;
                float2 _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2;
                Unity_Multiply_float2_float2(_Vector2_975b5ab1741c4306b35fd078943f2a9b_Out_0_Vector2, (_UV_014a305db25448bd996abe2571b3b9f7_Out_0_Vector4.xy), _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2);
                float _Split_b8943aa628d940eca15eb3b25811830d_R_1_Float = _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2[0];
                float _Split_b8943aa628d940eca15eb3b25811830d_G_2_Float = _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2[1];
                float _Split_b8943aa628d940eca15eb3b25811830d_B_3_Float = 0;
                float _Split_b8943aa628d940eca15eb3b25811830d_A_4_Float = 0;
                float _Property_0035a53e7767413991dbd5ba524bad8b_Out_0_Float = _flowSpeedDirection;
                float _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_0035a53e7767413991dbd5ba524bad8b_Out_0_Float, _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float);
                float _Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float;
                Unity_Add_float(_Split_b8943aa628d940eca15eb3b25811830d_G_2_Float, _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float, _Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float);
                float _Property_f5e31c45b6834d21b6d84b23ff13f8ca_Out_0_Float = _flowVariation;
                float _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float;
                Unity_Multiply_float_float(_Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float, _Property_f5e31c45b6834d21b6d84b23ff13f8ca_Out_0_Float, _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float);
                float2 _Vector2_d46c77108c2746bb84b1736f9377bfaa_Out_0_Vector2 = float2(_Split_b8943aa628d940eca15eb3b25811830d_R_1_Float, _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float);
                float _Property_aec8d8d2c3534733985d0190c8679917_Out_0_Float = _shineScale;
                float _SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float;
                Unity_SimpleNoise_LegacySine_float(_Vector2_d46c77108c2746bb84b1736f9377bfaa_Out_0_Vector2, _Property_aec8d8d2c3534733985d0190c8679917_Out_0_Float, _SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float);
                float _Property_2811d65e01c04a57b0ed1784c539ccf7_Out_0_Float = _shineDiminish;
                float _Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float;
                Unity_Power_float(_SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float, _Property_2811d65e01c04a57b0ed1784c539ccf7_Out_0_Float, _Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float);
                float4 _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4 = IN.uv0;
                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_R_1_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[0];
                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[1];
                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_B_3_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[2];
                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_A_4_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[3];
                float _Property_1c0b93250a8c478792eb9bbcab1dd667_Out_0_Float = _shineVerticalOffset;
                float _Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float;
                Unity_Subtract_float(_Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float, _Property_1c0b93250a8c478792eb9bbcab1dd667_Out_0_Float, _Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float);
                float _Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float;
                Unity_Absolute_float(_Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float, _Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float);
                float _Property_6ab0084071244b11b52b9b9737d68456_Out_0_Float = _shineLength;
                float _Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float;
                Unity_Subtract_float(_Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float, _Property_6ab0084071244b11b52b9b9737d68456_Out_0_Float, _Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float);
                float _OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float;
                Unity_OneMinus_float(_Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float, _OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float);
                float _Property_0c58e09f6e3749d1b683b4971026a036_Out_0_Float = _shineConcentration;
                float _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float;
                Unity_Power_float(_OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float, _Property_0c58e09f6e3749d1b683b4971026a036_Out_0_Float, _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float);
                float _Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float;
                Unity_Multiply_float_float(_Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float, _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float, _Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float);
                float _OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float;
                Unity_OneMinus_float(_Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float, _OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float);
                float _Property_a82ecc5425114c2fa59012ea04e83de1_Out_0_Float = _shineBottomHeight;
                float _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float;
                Unity_Power_float(_OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float, _Property_a82ecc5425114c2fa59012ea04e83de1_Out_0_Float, _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float);
                float _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float;
                Unity_Add_float(_Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float, _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float, _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float);
                float _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float;
                Unity_Add_float(_Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float, _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float, _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float);
                float _Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float;
                Unity_Step_float(_Property_df930666d03542579f9e2f0617c60c0b_Out_0_Float, _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float, _Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float);
                float4 _Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4;
                Unity_Multiply_float4_float4(_Property_361bb62208d94436a8592182d9a62718_Out_0_Vector4, (_Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float.xxxx), _Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4);
                float4 _Property_c9b63e5bc4b4498fb1bc35eb07940bab_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(BaseColor) : BaseColor;
                float4 _Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4;
                Unity_Add_float4(_Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4, _Property_c9b63e5bc4b4498fb1bc35eb07940bab_Out_0_Vector4, _Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4);
                float4 _ScreenPosition_3ecb1ddb1ac94e6297284d6d06ef1786_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                float _Property_5c8b26fce3e54d9ebbc0a630046017d1_Out_0_Float = _waveDistortion;
                float3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3;
                float3x3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                float3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Position = IN.WorldSpacePosition;
                Unity_NormalFromHeight_Tangent_float(_SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float,_Property_5c8b26fce3e54d9ebbc0a630046017d1_Out_0_Float,_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Position,_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_TangentMatrix, _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3);
                float _Float_b40f001a2f51425db9113b19840e3923_Out_0_Float = 0.5;
                float3 _Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3;
                Unity_Multiply_float3_float3(_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3, (_Float_b40f001a2f51425db9113b19840e3923_Out_0_Float.xxx), _Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3);
                float2 _TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2;
                Unity_TilingAndOffset_float((_ScreenPosition_3ecb1ddb1ac94e6297284d6d06ef1786_Out_0_Vector4.xy), float2 (1, 1), (_Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3.xy), _TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2);
                float3 _SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3;
                Unity_SceneColor_float((float4(_TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2, 0.0, 1.0)), _SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3);
                float3 _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3;
                Unity_Blend_Screen_float3(_SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3, float3(0, 0, 0), _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3, 0.7);
                float3 _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3;
                Unity_Add_float3((_Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4.xyz), _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3, _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3);
                float3 _Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3;
                Unity_Add_float3((_InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float.xxx), _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3, _Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3);
                float _Property_472e66ef7f0e4be1a983e4188962d94c_Out_0_Float = innerFoamRadius;
                float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                float4 _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4;
                Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4);
                float4 _Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4;
                Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_472e66ef7f0e4be1a983e4188962d94c_Out_0_Float.xxxx), _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4, _Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4);
                float4 _OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4;
                Unity_OneMinus_float4(_Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4, _OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4);
                float3 _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3;
                Unity_Add_float3(_Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3, (_OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4.xyz), _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3);
                float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                surface.NormalWS = IN.WorldSpaceNormal;
                surface.Emission = _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3;
                surface.Metallic = 0.5;
                surface.Smoothness = 0.5;
                surface.Occlusion = 1;
                surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                output.uv0 = input.uv0;
                output.TimeParameters = _TimeParameters.xyz;

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



                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);

                // use bitangent on the fly like in hdrp
                // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

                // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                output.WorldSpaceBiTangent = renormFactor * bitang;

                output.WorldSpacePosition = input.positionWS;

                #if UNITY_UV_STARTS_AT_TOP
                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #else
                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                #endif

                output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                output.uv0 = input.texCoord0;
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
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif

            ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }

                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off

                // Debug
                // <None>

                // --------------------------------------------------
                // Pass

                HLSLPROGRAM

                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma instancing_options renderinglayer
                #pragma vertex vert
                #pragma fragment frag

                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
                #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
                #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
                #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
                #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
                #pragma multi_compile_fragment _ DEBUG_DISPLAY
                // GraphKeywords: <None>

                // Defines

                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_WS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define VARYINGS_NEED_SHADOW_COORD
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define _FOG_FRAGMENT 1
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define REQUIRE_OPAQUE_TEXTURE


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
                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
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
                     float4 uv1 : TEXCOORD1;
                     float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                     float4 positionCS : SV_POSITION;
                     float3 positionWS;
                     float3 normalWS;
                     float4 tangentWS;
                     float4 texCoord0;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
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
                     float3 WorldSpaceNormal;
                     float3 WorldSpaceTangent;
                     float3 WorldSpaceBiTangent;
                     float3 WorldSpacePosition;
                     float2 NDCPosition;
                     float2 PixelPosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                     float3 ObjectSpaceNormal;
                     float3 ObjectSpaceTangent;
                     float3 ObjectSpacePosition;
                     float4 uv0;
                     float3 TimeParameters;
                };
                struct PackedVaryings
                {
                     float4 positionCS : SV_POSITION;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV : INTERP0;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV : INTERP1;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh : INTERP2;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord : INTERP3;
                    #endif
                     float4 tangentWS : INTERP4;
                     float4 texCoord0 : INTERP5;
                     float4 fogFactorAndVertexLight : INTERP6;
                     float3 positionWS : INTERP7;
                     float3 normalWS : INTERP8;
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
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS.xyzw = input.tangentWS;
                    output.texCoord0.xyzw = input.texCoord0;
                    output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
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
                    #if defined(LIGHTMAP_ON)
                    output.staticLightmapUV = input.staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                    output.dynamicLightmapUV = input.dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.sh;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    output.shadowCoord = input.shadowCoord;
                    #endif
                    output.tangentWS = input.tangentWS.xyzw;
                    output.texCoord0 = input.texCoord0.xyzw;
                    output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
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
                float radiusGradient;
                float4 BaseColor;
                float innerFoamRadius;
                float _upperHalfRadius;
                float _bottomHalfRadius;
                float _watergap;
                float _flowSpeedDirection;
                float _flowVariation;
                float4 _shineColor;
                float _shineConcentration;
                float _shineDiminish;
                float _shineVerticalOffset;
                float _shineScale;
                float _shineLength;
                float _shineFoamMiddle;
                float _shineBottomHeight;
                float _waveEdgeWobbleSpeed;
                float _waveEdgeWobbleAmount;
                float _waveEdgeWobbleDistance;
                float _waveEdgeThickness;
                float _waveVerticalStrength;
                float _waveSpeed;
                float _waveThickness;
                float _waveDistortion;
                float _waveNoiseScale;
                CBUFFER_END


                    // Object and Global properties
                    float4 _NekoLegendsWaterfallObjectInteraction;
                    float _radius;

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

                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                    {
                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                    }

                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Preview_float(float In, out float Out)
                    {
                        Out = In;
                    }

                    void Unity_Add_float(float A, float B, out float Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Sine_float(float In, out float Out)
                    {
                        Out = sin(In);
                    }

                    void Unity_Step_float(float Edge, float In, out float Out)
                    {
                        Out = step(Edge, In);
                    }

                    void Unity_OneMinus_float(float In, out float Out)
                    {
                        Out = 1 - In;
                    }

                    void Unity_InvertColors_float(float In, float InvertColors, out float Out)
                    {
                        Out = abs(InvertColors - In);
                    }

                    void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                    {
                        Out = A * B;
                    }

                    float Unity_SimpleNoise_ValueNoise_LegacySine_float(float2 uv)
                    {
                        float2 i = floor(uv);
                        float2 f = frac(uv);
                        f = f * f * (3.0 - 2.0 * f);
                        uv = abs(frac(uv) - 0.5);
                        float2 c0 = i + float2(0.0, 0.0);
                        float2 c1 = i + float2(1.0, 0.0);
                        float2 c2 = i + float2(0.0, 1.0);
                        float2 c3 = i + float2(1.0, 1.0);
                        float r0; Hash_LegacySine_2_1_float(c0, r0);
                        float r1; Hash_LegacySine_2_1_float(c1, r1);
                        float r2; Hash_LegacySine_2_1_float(c2, r2);
                        float r3; Hash_LegacySine_2_1_float(c3, r3);
                        float bottomOfGrid = lerp(r0, r1, f.x);
                        float topOfGrid = lerp(r2, r3, f.x);
                        float t = lerp(bottomOfGrid, topOfGrid, f.y);
                        return t;
                    }

                    void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
                    {
                        float freq, amp;
                        Out = 0.0f;
                        freq = pow(2.0, float(0));
                        amp = pow(0.5, float(3 - 0));
                        Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                        freq = pow(2.0, float(1));
                        amp = pow(0.5, float(3 - 1));
                        Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                        freq = pow(2.0, float(2));
                        amp = pow(0.5, float(3 - 2));
                        Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                    }

                    void Unity_Power_float(float A, float B, out float Out)
                    {
                        Out = pow(A, B);
                    }

                    void Unity_Subtract_float(float A, float B, out float Out)
                    {
                        Out = A - B;
                    }

                    void Unity_Absolute_float(float In, out float Out)
                    {
                        Out = abs(In);
                    }

                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A * B;
                    }

                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
                    {

                                #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                                #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                                #endif
                        float3 worldDerivativeX = ddx(Position);
                        float3 worldDerivativeY = ddy(Position);

                        float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
                        float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
                        float d = dot(worldDerivativeX, crossY);
                        float sgn = d < 0.0 ? (-1.0f) : 1.0f;
                        float surface = sgn / max(0.000000000000001192093f, abs(d));

                        float dHdx = ddx(In);
                        float dHdy = ddy(In);
                        float3 surfGrad = surface * (dHdx * crossY + dHdy * crossX);
                        Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
                        Out = TransformWorldToTangent(Out, TangentMatrix);
                    }

                    void Unity_SceneColor_float(float4 UV, out float3 Out)
                    {
                        Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
                    }

                    void Unity_Blend_Screen_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
                    {
                        Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                        Out = lerp(Base, Out, Opacity);
                    }

                    void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                    {
                        Out = A + B;
                    }

                    void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                    {
                        float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                        float4 result2 = 2.0 * Base * Blend;
                        float4 zeroOrOne = step(Base, 0.5);
                        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                        Out = lerp(Base, Out, Opacity);
                    }

                    void Unity_Distance_float3(float3 A, float3 B, out float Out)
                    {
                        Out = distance(A, B);
                    }

                    void Unity_Comparison_Greater_float(float A, float B, out float Out)
                    {
                        Out = A > B ? 1 : 0;
                    }

                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                    {
                        Out = Predicate ? True : False;
                    }

                    void Unity_Lerp_float(float A, float B, float T, out float Out)
                    {
                        Out = lerp(A, B, T);
                    }

                    void Unity_Saturate_float4(float4 In, out float4 Out)
                    {
                        Out = saturate(In);
                    }

                    void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
                    {
                        Out = smoothstep(Edge1, Edge2, In);
                    }

                    void Unity_OneMinus_float4(float4 In, out float4 Out)
                    {
                        Out = 1 - In;
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
                        float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                        float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                        float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                        float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                        float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                        float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                        float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                        Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                        float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                        Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                        float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                        Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                        description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                        float3 NormalWS;
                        float3 Emission;
                        float Metallic;
                        float Smoothness;
                        float Occlusion;
                        float Alpha;
                    };

                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                    {
                        SurfaceDescription surface = (SurfaceDescription)0;
                        float _Property_8644a44b0c3a44b0b952c46eb7cf1f70_Out_0_Float = _waveEdgeThickness;
                        float _Float_027a96f62a99423392bab3be567316d3_Out_0_Float = _Property_8644a44b0c3a44b0b952c46eb7cf1f70_Out_0_Float;
                        float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                        float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                        float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                        float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                        float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                        float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                        Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                        float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                        float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                        float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                        Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                        float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                        float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                        Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                        float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                        Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                        float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                        float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                        Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                        float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                        Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                        float _Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float;
                        Unity_Step_float(_Float_027a96f62a99423392bab3be567316d3_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float);
                        float _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float;
                        Unity_OneMinus_float(_Float_027a96f62a99423392bab3be567316d3_Out_0_Float, _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float);
                        float _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float;
                        Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float, _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float);
                        float _Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float;
                        Unity_Multiply_float_float(_Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float, _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float, _Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float);
                        float _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float;
                        float _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_InvertColors = float(1);
                        Unity_InvertColors_float(_Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float, _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_InvertColors, _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float);
                        float4 _Property_361bb62208d94436a8592182d9a62718_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_shineColor) : _shineColor;
                        float _Property_df930666d03542579f9e2f0617c60c0b_Out_0_Float = _shineFoamMiddle;
                        float _Split_6e20ef5497714818850c8192df227845_R_1_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                                 length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                                 length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[0];
                        float _Split_6e20ef5497714818850c8192df227845_G_2_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                                 length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                                 length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[1];
                        float _Split_6e20ef5497714818850c8192df227845_B_3_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                                 length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                                 length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[2];
                        float _Split_6e20ef5497714818850c8192df227845_A_4_Float = 0;
                        float2 _Vector2_975b5ab1741c4306b35fd078943f2a9b_Out_0_Vector2 = float2(_Split_6e20ef5497714818850c8192df227845_R_1_Float, _Split_6e20ef5497714818850c8192df227845_B_3_Float);
                        float4 _UV_014a305db25448bd996abe2571b3b9f7_Out_0_Vector4 = IN.uv0;
                        float2 _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2;
                        Unity_Multiply_float2_float2(_Vector2_975b5ab1741c4306b35fd078943f2a9b_Out_0_Vector2, (_UV_014a305db25448bd996abe2571b3b9f7_Out_0_Vector4.xy), _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2);
                        float _Split_b8943aa628d940eca15eb3b25811830d_R_1_Float = _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2[0];
                        float _Split_b8943aa628d940eca15eb3b25811830d_G_2_Float = _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2[1];
                        float _Split_b8943aa628d940eca15eb3b25811830d_B_3_Float = 0;
                        float _Split_b8943aa628d940eca15eb3b25811830d_A_4_Float = 0;
                        float _Property_0035a53e7767413991dbd5ba524bad8b_Out_0_Float = _flowSpeedDirection;
                        float _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_0035a53e7767413991dbd5ba524bad8b_Out_0_Float, _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float);
                        float _Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float;
                        Unity_Add_float(_Split_b8943aa628d940eca15eb3b25811830d_G_2_Float, _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float, _Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float);
                        float _Property_f5e31c45b6834d21b6d84b23ff13f8ca_Out_0_Float = _flowVariation;
                        float _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float;
                        Unity_Multiply_float_float(_Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float, _Property_f5e31c45b6834d21b6d84b23ff13f8ca_Out_0_Float, _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float);
                        float2 _Vector2_d46c77108c2746bb84b1736f9377bfaa_Out_0_Vector2 = float2(_Split_b8943aa628d940eca15eb3b25811830d_R_1_Float, _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float);
                        float _Property_aec8d8d2c3534733985d0190c8679917_Out_0_Float = _shineScale;
                        float _SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float;
                        Unity_SimpleNoise_LegacySine_float(_Vector2_d46c77108c2746bb84b1736f9377bfaa_Out_0_Vector2, _Property_aec8d8d2c3534733985d0190c8679917_Out_0_Float, _SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float);
                        float _Property_2811d65e01c04a57b0ed1784c539ccf7_Out_0_Float = _shineDiminish;
                        float _Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float;
                        Unity_Power_float(_SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float, _Property_2811d65e01c04a57b0ed1784c539ccf7_Out_0_Float, _Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float);
                        float4 _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4 = IN.uv0;
                        float _Split_5b4bfc8f6cca43f28b693f3288791fd2_R_1_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[0];
                        float _Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[1];
                        float _Split_5b4bfc8f6cca43f28b693f3288791fd2_B_3_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[2];
                        float _Split_5b4bfc8f6cca43f28b693f3288791fd2_A_4_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[3];
                        float _Property_1c0b93250a8c478792eb9bbcab1dd667_Out_0_Float = _shineVerticalOffset;
                        float _Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float;
                        Unity_Subtract_float(_Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float, _Property_1c0b93250a8c478792eb9bbcab1dd667_Out_0_Float, _Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float);
                        float _Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float;
                        Unity_Absolute_float(_Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float, _Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float);
                        float _Property_6ab0084071244b11b52b9b9737d68456_Out_0_Float = _shineLength;
                        float _Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float;
                        Unity_Subtract_float(_Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float, _Property_6ab0084071244b11b52b9b9737d68456_Out_0_Float, _Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float);
                        float _OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float;
                        Unity_OneMinus_float(_Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float, _OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float);
                        float _Property_0c58e09f6e3749d1b683b4971026a036_Out_0_Float = _shineConcentration;
                        float _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float;
                        Unity_Power_float(_OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float, _Property_0c58e09f6e3749d1b683b4971026a036_Out_0_Float, _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float);
                        float _Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float;
                        Unity_Multiply_float_float(_Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float, _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float, _Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float);
                        float _OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float;
                        Unity_OneMinus_float(_Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float, _OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float);
                        float _Property_a82ecc5425114c2fa59012ea04e83de1_Out_0_Float = _shineBottomHeight;
                        float _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float;
                        Unity_Power_float(_OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float, _Property_a82ecc5425114c2fa59012ea04e83de1_Out_0_Float, _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float);
                        float _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float;
                        Unity_Add_float(_Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float, _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float, _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float);
                        float _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float;
                        Unity_Add_float(_Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float, _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float, _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float);
                        float _Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float;
                        Unity_Step_float(_Property_df930666d03542579f9e2f0617c60c0b_Out_0_Float, _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float, _Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float);
                        float4 _Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4;
                        Unity_Multiply_float4_float4(_Property_361bb62208d94436a8592182d9a62718_Out_0_Vector4, (_Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float.xxxx), _Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4);
                        float4 _Property_c9b63e5bc4b4498fb1bc35eb07940bab_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(BaseColor) : BaseColor;
                        float4 _Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4;
                        Unity_Add_float4(_Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4, _Property_c9b63e5bc4b4498fb1bc35eb07940bab_Out_0_Vector4, _Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4);
                        float4 _ScreenPosition_3ecb1ddb1ac94e6297284d6d06ef1786_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                        float _Property_5c8b26fce3e54d9ebbc0a630046017d1_Out_0_Float = _waveDistortion;
                        float3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3;
                        float3x3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                        float3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Position = IN.WorldSpacePosition;
                        Unity_NormalFromHeight_Tangent_float(_SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float,_Property_5c8b26fce3e54d9ebbc0a630046017d1_Out_0_Float,_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Position,_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_TangentMatrix, _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3);
                        float _Float_b40f001a2f51425db9113b19840e3923_Out_0_Float = 0.5;
                        float3 _Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3;
                        Unity_Multiply_float3_float3(_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3, (_Float_b40f001a2f51425db9113b19840e3923_Out_0_Float.xxx), _Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3);
                        float2 _TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2;
                        Unity_TilingAndOffset_float((_ScreenPosition_3ecb1ddb1ac94e6297284d6d06ef1786_Out_0_Vector4.xy), float2 (1, 1), (_Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3.xy), _TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2);
                        float3 _SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3;
                        Unity_SceneColor_float((float4(_TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2, 0.0, 1.0)), _SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3);
                        float3 _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3;
                        Unity_Blend_Screen_float3(_SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3, float3(0, 0, 0), _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3, 0.7);
                        float3 _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3;
                        Unity_Add_float3((_Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4.xyz), _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3, _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3);
                        float3 _Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3;
                        Unity_Add_float3((_InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float.xxx), _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3, _Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3);
                        float _Property_472e66ef7f0e4be1a983e4188962d94c_Out_0_Float = innerFoamRadius;
                        float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                        float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                        float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                        float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                        float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                        float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                        Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                        float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                        Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                        float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                        Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                        float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                        float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                        Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                        float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                        Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                        float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                        float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                        Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                        float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                        Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                        float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                        Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                        float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                        Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                        float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                        float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                        Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                        float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                        float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                        float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                        float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                        float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                        float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                        float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                        float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                        float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                        float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                        float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                        float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                        Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                        float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                        float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                        Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                        float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                        float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                        Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                        float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                        float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                        Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                        float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                        float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                        Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                        float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                        Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                        float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                        float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                        float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                        float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                        float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                        float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                        Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                        float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                        float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                        Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                        float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                        float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                        Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                        float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                        Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                        float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                        Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                        float4 _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4;
                        Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4);
                        float4 _Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4;
                        Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_472e66ef7f0e4be1a983e4188962d94c_Out_0_Float.xxxx), _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4, _Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4);
                        float4 _OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4;
                        Unity_OneMinus_float4(_Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4, _OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4);
                        float3 _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3;
                        Unity_Add_float3(_Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3, (_OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4.xyz), _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3);
                        float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                        float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                        Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                        float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                        Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                        float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                        Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                        float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                        Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                        float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                        float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                        Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                        float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                        Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                        float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                        Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                        surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                        surface.NormalWS = IN.WorldSpaceNormal;
                        surface.Emission = _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3;
                        surface.Metallic = 0.5;
                        surface.Smoothness = 0.5;
                        surface.Occlusion = 1;
                        surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                        output.uv0 = input.uv0;
                        output.TimeParameters = _TimeParameters.xyz;

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



                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                        float3 unnormalizedNormalWS = input.normalWS;
                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);

                        // use bitangent on the fly like in hdrp
                        // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                        float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                        float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

                        // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                        // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                        output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                        output.WorldSpaceBiTangent = renormFactor * bitang;

                        output.WorldSpacePosition = input.positionWS;

                        #if UNITY_UV_STARTS_AT_TOP
                        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                        #else
                        output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                        #endif

                        output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                        output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                        output.uv0 = input.texCoord0;
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
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

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
                        Cull Off
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

                        #define _NORMALMAP 1
                        #define _NORMAL_DROPOFF_WS 1
                        #define ATTRIBUTES_NEED_NORMAL
                        #define ATTRIBUTES_NEED_TANGENT
                        #define ATTRIBUTES_NEED_TEXCOORD0
                        #define VARYINGS_NEED_POSITION_WS
                        #define VARYINGS_NEED_NORMAL_WS
                        #define VARYINGS_NEED_TEXCOORD0
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
                        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
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
                             float3 WorldSpacePosition;
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct VertexDescriptionInputs
                        {
                             float3 ObjectSpaceNormal;
                             float3 ObjectSpaceTangent;
                             float3 ObjectSpacePosition;
                             float4 uv0;
                             float3 TimeParameters;
                        };
                        struct PackedVaryings
                        {
                             float4 positionCS : SV_POSITION;
                             float4 texCoord0 : INTERP0;
                             float3 positionWS : INTERP1;
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
                        float radiusGradient;
                        float4 BaseColor;
                        float innerFoamRadius;
                        float _upperHalfRadius;
                        float _bottomHalfRadius;
                        float _watergap;
                        float _flowSpeedDirection;
                        float _flowVariation;
                        float4 _shineColor;
                        float _shineConcentration;
                        float _shineDiminish;
                        float _shineVerticalOffset;
                        float _shineScale;
                        float _shineLength;
                        float _shineFoamMiddle;
                        float _shineBottomHeight;
                        float _waveEdgeWobbleSpeed;
                        float _waveEdgeWobbleAmount;
                        float _waveEdgeWobbleDistance;
                        float _waveEdgeThickness;
                        float _waveVerticalStrength;
                        float _waveSpeed;
                        float _waveThickness;
                        float _waveDistortion;
                        float _waveNoiseScale;
                        CBUFFER_END


                            // Object and Global properties
                            float4 _NekoLegendsWaterfallObjectInteraction;
                            float _radius;

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

                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                            {
                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                            }

                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                            {
                                Out = A * B;
                            }

                            void Unity_Preview_float(float In, out float Out)
                            {
                                Out = In;
                            }

                            void Unity_Add_float(float A, float B, out float Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Sine_float(float In, out float Out)
                            {
                                Out = sin(In);
                            }

                            void Unity_Step_float(float Edge, float In, out float Out)
                            {
                                Out = step(Edge, In);
                            }

                            void Unity_OneMinus_float(float In, out float Out)
                            {
                                Out = 1 - In;
                            }

                            void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                            {
                                float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                float4 result2 = 2.0 * Base * Blend;
                                float4 zeroOrOne = step(Base, 0.5);
                                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                Out = lerp(Base, Out, Opacity);
                            }

                            void Unity_Distance_float3(float3 A, float3 B, out float Out)
                            {
                                Out = distance(A, B);
                            }

                            void Unity_Subtract_float(float A, float B, out float Out)
                            {
                                Out = A - B;
                            }

                            void Unity_Comparison_Greater_float(float A, float B, out float Out)
                            {
                                Out = A > B ? 1 : 0;
                            }

                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                            {
                                Out = Predicate ? True : False;
                            }

                            void Unity_Lerp_float(float A, float B, float T, out float Out)
                            {
                                Out = lerp(A, B, T);
                            }

                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                            {
                                Out = A + B;
                            }

                            void Unity_Saturate_float4(float4 In, out float4 Out)
                            {
                                Out = saturate(In);
                            }

                            void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
                            {
                                Out = smoothstep(Edge1, Edge2, In);
                            }

                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                            {
                                Out = A * B;
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
                                float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                                float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                                float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                                float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                                float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                                float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                                float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                                Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                                float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                                Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                                float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                                Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                                description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                                float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                                float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                                float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                                float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                                float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                                float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                                float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                                Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                                float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                                float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                                float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                                Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                                float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                                float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                                Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                                float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                                Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                                float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                                float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                                Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                                float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                                Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                                float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                                Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                                float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                                Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                                float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                                Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                                float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                                Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                                float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                                float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                                float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                                float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                                float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                                float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                                float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                                Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                                float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                                Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                                float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                                Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                                float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                                float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                                Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                                float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                                Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                                float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                                float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                                Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                                float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                                Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                                float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                                Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                                float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                                Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                                float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                                Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                                float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                                float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                                float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                                float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                                float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                                float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                                float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                                float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                                float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                                float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                                float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                                Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                                float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                                float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                                Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                                float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                                float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                                Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                                float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                                Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                                float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                                float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                                Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                                float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                                Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                                float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                                float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                                float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                                float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                                float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                                float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                                Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                                float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                                float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                                Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                                float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                                float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                                Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                                float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                                Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                                float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                                Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                                float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                                Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                                float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                                Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                                float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                                Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                                surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                                output.uv0 = input.uv0;
                                output.TimeParameters = _TimeParameters.xyz;

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







                                output.WorldSpacePosition = input.positionWS;

                                #if UNITY_UV_STARTS_AT_TOP
                                #else
                                #endif


                                output.uv0 = input.texCoord0;
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
                                Name "DepthNormals"
                                Tags
                                {
                                    "LightMode" = "DepthNormals"
                                }

                                // Render State
                                Cull Off
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
                                // PassKeywords: <None>
                                // GraphKeywords: <None>

                                // Defines

                                #define _NORMALMAP 1
                                #define _NORMAL_DROPOFF_WS 1
                                #define ATTRIBUTES_NEED_NORMAL
                                #define ATTRIBUTES_NEED_TANGENT
                                #define ATTRIBUTES_NEED_TEXCOORD0
                                #define ATTRIBUTES_NEED_TEXCOORD1
                                #define VARYINGS_NEED_POSITION_WS
                                #define VARYINGS_NEED_NORMAL_WS
                                #define VARYINGS_NEED_TANGENT_WS
                                #define VARYINGS_NEED_TEXCOORD0
                                #define FEATURES_GRAPH_VERTEX
                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                #define SHADERPASS SHADERPASS_DEPTHNORMALS


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
                                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
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
                                     float4 uv1 : TEXCOORD1;
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                     uint instanceID : INSTANCEID_SEMANTIC;
                                    #endif
                                };
                                struct Varyings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float3 positionWS;
                                     float3 normalWS;
                                     float4 tangentWS;
                                     float4 texCoord0;
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
                                     float3 WorldSpaceNormal;
                                     float3 WorldSpacePosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct VertexDescriptionInputs
                                {
                                     float3 ObjectSpaceNormal;
                                     float3 ObjectSpaceTangent;
                                     float3 ObjectSpacePosition;
                                     float4 uv0;
                                     float3 TimeParameters;
                                };
                                struct PackedVaryings
                                {
                                     float4 positionCS : SV_POSITION;
                                     float4 tangentWS : INTERP0;
                                     float4 texCoord0 : INTERP1;
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
                                    output.tangentWS.xyzw = input.tangentWS;
                                    output.texCoord0.xyzw = input.texCoord0;
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
                                    output.tangentWS = input.tangentWS.xyzw;
                                    output.texCoord0 = input.texCoord0.xyzw;
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
                                float radiusGradient;
                                float4 BaseColor;
                                float innerFoamRadius;
                                float _upperHalfRadius;
                                float _bottomHalfRadius;
                                float _watergap;
                                float _flowSpeedDirection;
                                float _flowVariation;
                                float4 _shineColor;
                                float _shineConcentration;
                                float _shineDiminish;
                                float _shineVerticalOffset;
                                float _shineScale;
                                float _shineLength;
                                float _shineFoamMiddle;
                                float _shineBottomHeight;
                                float _waveEdgeWobbleSpeed;
                                float _waveEdgeWobbleAmount;
                                float _waveEdgeWobbleDistance;
                                float _waveEdgeThickness;
                                float _waveVerticalStrength;
                                float _waveSpeed;
                                float _waveThickness;
                                float _waveDistortion;
                                float _waveNoiseScale;
                                CBUFFER_END


                                    // Object and Global properties
                                    float4 _NekoLegendsWaterfallObjectInteraction;
                                    float _radius;

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

                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                    {
                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                    }

                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                    {
                                        Out = A * B;
                                    }

                                    void Unity_Preview_float(float In, out float Out)
                                    {
                                        Out = In;
                                    }

                                    void Unity_Add_float(float A, float B, out float Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Sine_float(float In, out float Out)
                                    {
                                        Out = sin(In);
                                    }

                                    void Unity_Step_float(float Edge, float In, out float Out)
                                    {
                                        Out = step(Edge, In);
                                    }

                                    void Unity_OneMinus_float(float In, out float Out)
                                    {
                                        Out = 1 - In;
                                    }

                                    void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                    {
                                        float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                        float4 result2 = 2.0 * Base * Blend;
                                        float4 zeroOrOne = step(Base, 0.5);
                                        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                        Out = lerp(Base, Out, Opacity);
                                    }

                                    void Unity_Distance_float3(float3 A, float3 B, out float Out)
                                    {
                                        Out = distance(A, B);
                                    }

                                    void Unity_Subtract_float(float A, float B, out float Out)
                                    {
                                        Out = A - B;
                                    }

                                    void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                    {
                                        Out = A > B ? 1 : 0;
                                    }

                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                    {
                                        Out = Predicate ? True : False;
                                    }

                                    void Unity_Lerp_float(float A, float B, float T, out float Out)
                                    {
                                        Out = lerp(A, B, T);
                                    }

                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A + B;
                                    }

                                    void Unity_Saturate_float4(float4 In, out float4 Out)
                                    {
                                        Out = saturate(In);
                                    }

                                    void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
                                    {
                                        Out = smoothstep(Edge1, Edge2, In);
                                    }

                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                    {
                                        Out = A * B;
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
                                        float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                                        float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                                        float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                                        float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                                        float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                                        float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                                        float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                                        Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                                        float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                                        Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                                        float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                                        Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                                        description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                                        float3 NormalWS;
                                        float Alpha;
                                    };

                                    SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                    {
                                        SurfaceDescription surface = (SurfaceDescription)0;
                                        float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                                        float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                                        float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                                        float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                                        float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                                        float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                                        float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                                        Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                                        float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                                        float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                                        float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                                        Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                                        float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                                        float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                                        Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                                        float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                                        Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                                        float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                                        float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                                        Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                                        float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                                        Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                                        float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                                        Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                                        float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                                        Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                                        float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                                        Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                                        float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                                        Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                                        float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                                        float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                                        float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                                        float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                                        float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                                        float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                                        float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                                        Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                                        float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                                        Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                                        float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                                        Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                                        float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                                        float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                                        Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                                        float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                                        Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                                        float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                                        float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                                        Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                                        float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                                        Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                                        float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                                        Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                                        float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                                        Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                                        float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                        float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                                        Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                                        float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                                        float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                        float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                                        float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                                        float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                                        float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                                        float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                                        float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                                        Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                                        float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                                        float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                                        Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                                        float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                                        float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                                        Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                                        float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                        float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                                        Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                                        float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                                        float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                                        Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                                        float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                                        Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                                        float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                                        float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                                        float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                                        float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                                        float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                                        float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                                        Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                                        float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                                        float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                                        Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                                        float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                                        float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                                        Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                                        float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                                        Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                                        float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                                        Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                                        float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                                        Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                                        float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                                        Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                                        float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                                        Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                                        surface.NormalWS = IN.WorldSpaceNormal;
                                        surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                                        output.uv0 = input.uv0;
                                        output.TimeParameters = _TimeParameters.xyz;

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



                                        // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                        float3 unnormalizedNormalWS = input.normalWS;
                                        const float renormFactor = 1.0 / length(unnormalizedNormalWS);


                                        output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph


                                        output.WorldSpacePosition = input.positionWS;

                                        #if UNITY_UV_STARTS_AT_TOP
                                        #else
                                        #endif


                                        output.uv0 = input.texCoord0;
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
                                        Name "Meta"
                                        Tags
                                        {
                                            "LightMode" = "Meta"
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
                                        #pragma shader_feature _ EDITOR_VISUALIZATION
                                        // GraphKeywords: <None>

                                        // Defines

                                        #define _NORMALMAP 1
                                        #define _NORMAL_DROPOFF_WS 1
                                        #define ATTRIBUTES_NEED_NORMAL
                                        #define ATTRIBUTES_NEED_TANGENT
                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                        #define ATTRIBUTES_NEED_TEXCOORD1
                                        #define ATTRIBUTES_NEED_TEXCOORD2
                                        #define VARYINGS_NEED_POSITION_WS
                                        #define VARYINGS_NEED_NORMAL_WS
                                        #define VARYINGS_NEED_TANGENT_WS
                                        #define VARYINGS_NEED_TEXCOORD0
                                        #define VARYINGS_NEED_TEXCOORD1
                                        #define VARYINGS_NEED_TEXCOORD2
                                        #define FEATURES_GRAPH_VERTEX
                                        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                        #define SHADERPASS SHADERPASS_META
                                        #define _FOG_FRAGMENT 1
                                        #define REQUIRE_OPAQUE_TEXTURE


                                        // custom interpolator pre-include
                                        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                        // Includes
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
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
                                             float4 uv1 : TEXCOORD1;
                                             float4 uv2 : TEXCOORD2;
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                             uint instanceID : INSTANCEID_SEMANTIC;
                                            #endif
                                        };
                                        struct Varyings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float3 positionWS;
                                             float3 normalWS;
                                             float4 tangentWS;
                                             float4 texCoord0;
                                             float4 texCoord1;
                                             float4 texCoord2;
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
                                             float3 WorldSpaceNormal;
                                             float3 WorldSpaceTangent;
                                             float3 WorldSpaceBiTangent;
                                             float3 WorldSpacePosition;
                                             float2 NDCPosition;
                                             float2 PixelPosition;
                                             float4 uv0;
                                             float3 TimeParameters;
                                        };
                                        struct VertexDescriptionInputs
                                        {
                                             float3 ObjectSpaceNormal;
                                             float3 ObjectSpaceTangent;
                                             float3 ObjectSpacePosition;
                                             float4 uv0;
                                             float3 TimeParameters;
                                        };
                                        struct PackedVaryings
                                        {
                                             float4 positionCS : SV_POSITION;
                                             float4 tangentWS : INTERP0;
                                             float4 texCoord0 : INTERP1;
                                             float4 texCoord1 : INTERP2;
                                             float4 texCoord2 : INTERP3;
                                             float3 positionWS : INTERP4;
                                             float3 normalWS : INTERP5;
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
                                            output.tangentWS.xyzw = input.tangentWS;
                                            output.texCoord0.xyzw = input.texCoord0;
                                            output.texCoord1.xyzw = input.texCoord1;
                                            output.texCoord2.xyzw = input.texCoord2;
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
                                            output.tangentWS = input.tangentWS.xyzw;
                                            output.texCoord0 = input.texCoord0.xyzw;
                                            output.texCoord1 = input.texCoord1.xyzw;
                                            output.texCoord2 = input.texCoord2.xyzw;
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
                                        float radiusGradient;
                                        float4 BaseColor;
                                        float innerFoamRadius;
                                        float _upperHalfRadius;
                                        float _bottomHalfRadius;
                                        float _watergap;
                                        float _flowSpeedDirection;
                                        float _flowVariation;
                                        float4 _shineColor;
                                        float _shineConcentration;
                                        float _shineDiminish;
                                        float _shineVerticalOffset;
                                        float _shineScale;
                                        float _shineLength;
                                        float _shineFoamMiddle;
                                        float _shineBottomHeight;
                                        float _waveEdgeWobbleSpeed;
                                        float _waveEdgeWobbleAmount;
                                        float _waveEdgeWobbleDistance;
                                        float _waveEdgeThickness;
                                        float _waveVerticalStrength;
                                        float _waveSpeed;
                                        float _waveThickness;
                                        float _waveDistortion;
                                        float _waveNoiseScale;
                                        CBUFFER_END


                                            // Object and Global properties
                                            float4 _NekoLegendsWaterfallObjectInteraction;
                                            float _radius;

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

                                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                            {
                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                            }

                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Preview_float(float In, out float Out)
                                            {
                                                Out = In;
                                            }

                                            void Unity_Add_float(float A, float B, out float Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Sine_float(float In, out float Out)
                                            {
                                                Out = sin(In);
                                            }

                                            void Unity_Step_float(float Edge, float In, out float Out)
                                            {
                                                Out = step(Edge, In);
                                            }

                                            void Unity_OneMinus_float(float In, out float Out)
                                            {
                                                Out = 1 - In;
                                            }

                                            void Unity_InvertColors_float(float In, float InvertColors, out float Out)
                                            {
                                                Out = abs(InvertColors - In);
                                            }

                                            void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                            {
                                                Out = A * B;
                                            }

                                            float Unity_SimpleNoise_ValueNoise_LegacySine_float(float2 uv)
                                            {
                                                float2 i = floor(uv);
                                                float2 f = frac(uv);
                                                f = f * f * (3.0 - 2.0 * f);
                                                uv = abs(frac(uv) - 0.5);
                                                float2 c0 = i + float2(0.0, 0.0);
                                                float2 c1 = i + float2(1.0, 0.0);
                                                float2 c2 = i + float2(0.0, 1.0);
                                                float2 c3 = i + float2(1.0, 1.0);
                                                float r0; Hash_LegacySine_2_1_float(c0, r0);
                                                float r1; Hash_LegacySine_2_1_float(c1, r1);
                                                float r2; Hash_LegacySine_2_1_float(c2, r2);
                                                float r3; Hash_LegacySine_2_1_float(c3, r3);
                                                float bottomOfGrid = lerp(r0, r1, f.x);
                                                float topOfGrid = lerp(r2, r3, f.x);
                                                float t = lerp(bottomOfGrid, topOfGrid, f.y);
                                                return t;
                                            }

                                            void Unity_SimpleNoise_LegacySine_float(float2 UV, float Scale, out float Out)
                                            {
                                                float freq, amp;
                                                Out = 0.0f;
                                                freq = pow(2.0, float(0));
                                                amp = pow(0.5, float(3 - 0));
                                                Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                                                freq = pow(2.0, float(1));
                                                amp = pow(0.5, float(3 - 1));
                                                Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                                                freq = pow(2.0, float(2));
                                                amp = pow(0.5, float(3 - 2));
                                                Out += Unity_SimpleNoise_ValueNoise_LegacySine_float(float2(UV.xy * (Scale / freq))) * amp;
                                            }

                                            void Unity_Power_float(float A, float B, out float Out)
                                            {
                                                Out = pow(A, B);
                                            }

                                            void Unity_Subtract_float(float A, float B, out float Out)
                                            {
                                                Out = A - B;
                                            }

                                            void Unity_Absolute_float(float In, out float Out)
                                            {
                                                Out = abs(In);
                                            }

                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A * B;
                                            }

                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
                                            {

                                                        #if defined(SHADER_STAGE_RAY_TRACING) && defined(RAYTRACING_SHADER_GRAPH_DEFAULT)
                                                        #error 'Normal From Height' node is not supported in ray tracing, please provide an alternate implementation, relying for instance on the 'Raytracing Quality' keyword
                                                        #endif
                                                float3 worldDerivativeX = ddx(Position);
                                                float3 worldDerivativeY = ddy(Position);

                                                float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
                                                float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
                                                float d = dot(worldDerivativeX, crossY);
                                                float sgn = d < 0.0 ? (-1.0f) : 1.0f;
                                                float surface = sgn / max(0.000000000000001192093f, abs(d));

                                                float dHdx = ddx(In);
                                                float dHdy = ddy(In);
                                                float3 surfGrad = surface * (dHdx * crossY + dHdy * crossX);
                                                Out = SafeNormalize(TangentMatrix[2].xyz - (Strength * surfGrad));
                                                Out = TransformWorldToTangent(Out, TangentMatrix);
                                            }

                                            void Unity_SceneColor_float(float4 UV, out float3 Out)
                                            {
                                                Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
                                            }

                                            void Unity_Blend_Screen_float3(float3 Base, float3 Blend, out float3 Out, float Opacity)
                                            {
                                                Out = 1.0 - (1.0 - Blend) * (1.0 - Base);
                                                Out = lerp(Base, Out, Opacity);
                                            }

                                            void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                                            {
                                                Out = A + B;
                                            }

                                            void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                            {
                                                float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                                float4 result2 = 2.0 * Base * Blend;
                                                float4 zeroOrOne = step(Base, 0.5);
                                                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                                Out = lerp(Base, Out, Opacity);
                                            }

                                            void Unity_Distance_float3(float3 A, float3 B, out float Out)
                                            {
                                                Out = distance(A, B);
                                            }

                                            void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                            {
                                                Out = A > B ? 1 : 0;
                                            }

                                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                            {
                                                Out = Predicate ? True : False;
                                            }

                                            void Unity_Lerp_float(float A, float B, float T, out float Out)
                                            {
                                                Out = lerp(A, B, T);
                                            }

                                            void Unity_Saturate_float4(float4 In, out float4 Out)
                                            {
                                                Out = saturate(In);
                                            }

                                            void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
                                            {
                                                Out = smoothstep(Edge1, Edge2, In);
                                            }

                                            void Unity_OneMinus_float4(float4 In, out float4 Out)
                                            {
                                                Out = 1 - In;
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
                                                float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                                                float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                                                float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                                                float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                                                float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                                                float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                                                float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                                                Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                                                float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                                                Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                                                float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                                                Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                                                description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                                                float3 Emission;
                                                float Alpha;
                                            };

                                            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                            {
                                                SurfaceDescription surface = (SurfaceDescription)0;
                                                float _Property_8644a44b0c3a44b0b952c46eb7cf1f70_Out_0_Float = _waveEdgeThickness;
                                                float _Float_027a96f62a99423392bab3be567316d3_Out_0_Float = _Property_8644a44b0c3a44b0b952c46eb7cf1f70_Out_0_Float;
                                                float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                                                float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                                                float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                                                float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                                                float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                                                float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                                                Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                                                float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                                                float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                                                float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                                                Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                                                float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                                                float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                                                Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                                                float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                                                Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                                                float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                                                float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                                                Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                                                float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                                                Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                                                float _Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float;
                                                Unity_Step_float(_Float_027a96f62a99423392bab3be567316d3_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float);
                                                float _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float;
                                                Unity_OneMinus_float(_Float_027a96f62a99423392bab3be567316d3_Out_0_Float, _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float);
                                                float _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float;
                                                Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_752e0b4e1822436eb5fbe11847908eb3_Out_1_Float, _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float);
                                                float _Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float;
                                                Unity_Multiply_float_float(_Step_e9458f02c3904fa4bbb5d70936a9c197_Out_2_Float, _Step_6da159c3f5c04341be86cdf8ace654f3_Out_2_Float, _Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float);
                                                float _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float;
                                                float _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_InvertColors = float(1);
                                                Unity_InvertColors_float(_Multiply_837dcb0efbc14d53ad12b13cdc25cebf_Out_2_Float, _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_InvertColors, _InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float);
                                                float4 _Property_361bb62208d94436a8592182d9a62718_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(_shineColor) : _shineColor;
                                                float _Property_df930666d03542579f9e2f0617c60c0b_Out_0_Float = _shineFoamMiddle;
                                                float _Split_6e20ef5497714818850c8192df227845_R_1_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                                                         length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                                                         length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[0];
                                                float _Split_6e20ef5497714818850c8192df227845_G_2_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                                                         length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                                                         length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[1];
                                                float _Split_6e20ef5497714818850c8192df227845_B_3_Float = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                                                         length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                                                         length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)))[2];
                                                float _Split_6e20ef5497714818850c8192df227845_A_4_Float = 0;
                                                float2 _Vector2_975b5ab1741c4306b35fd078943f2a9b_Out_0_Vector2 = float2(_Split_6e20ef5497714818850c8192df227845_R_1_Float, _Split_6e20ef5497714818850c8192df227845_B_3_Float);
                                                float4 _UV_014a305db25448bd996abe2571b3b9f7_Out_0_Vector4 = IN.uv0;
                                                float2 _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2;
                                                Unity_Multiply_float2_float2(_Vector2_975b5ab1741c4306b35fd078943f2a9b_Out_0_Vector2, (_UV_014a305db25448bd996abe2571b3b9f7_Out_0_Vector4.xy), _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2);
                                                float _Split_b8943aa628d940eca15eb3b25811830d_R_1_Float = _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2[0];
                                                float _Split_b8943aa628d940eca15eb3b25811830d_G_2_Float = _Multiply_7ba420cd72664d50886810bb731b22c8_Out_2_Vector2[1];
                                                float _Split_b8943aa628d940eca15eb3b25811830d_B_3_Float = 0;
                                                float _Split_b8943aa628d940eca15eb3b25811830d_A_4_Float = 0;
                                                float _Property_0035a53e7767413991dbd5ba524bad8b_Out_0_Float = _flowSpeedDirection;
                                                float _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_0035a53e7767413991dbd5ba524bad8b_Out_0_Float, _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float);
                                                float _Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float;
                                                Unity_Add_float(_Split_b8943aa628d940eca15eb3b25811830d_G_2_Float, _Multiply_2aa9c6100a8b47f2810e2e713e8666b3_Out_2_Float, _Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float);
                                                float _Property_f5e31c45b6834d21b6d84b23ff13f8ca_Out_0_Float = _flowVariation;
                                                float _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float;
                                                Unity_Multiply_float_float(_Add_60a0b04a311c42dc8cc3c117008f8897_Out_2_Float, _Property_f5e31c45b6834d21b6d84b23ff13f8ca_Out_0_Float, _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float);
                                                float2 _Vector2_d46c77108c2746bb84b1736f9377bfaa_Out_0_Vector2 = float2(_Split_b8943aa628d940eca15eb3b25811830d_R_1_Float, _Multiply_f154a859c70843b4b5007885897805d7_Out_2_Float);
                                                float _Property_aec8d8d2c3534733985d0190c8679917_Out_0_Float = _shineScale;
                                                float _SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float;
                                                Unity_SimpleNoise_LegacySine_float(_Vector2_d46c77108c2746bb84b1736f9377bfaa_Out_0_Vector2, _Property_aec8d8d2c3534733985d0190c8679917_Out_0_Float, _SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float);
                                                float _Property_2811d65e01c04a57b0ed1784c539ccf7_Out_0_Float = _shineDiminish;
                                                float _Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float;
                                                Unity_Power_float(_SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float, _Property_2811d65e01c04a57b0ed1784c539ccf7_Out_0_Float, _Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float);
                                                float4 _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4 = IN.uv0;
                                                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_R_1_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[0];
                                                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[1];
                                                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_B_3_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[2];
                                                float _Split_5b4bfc8f6cca43f28b693f3288791fd2_A_4_Float = _UV_92bda1a83a414e8d80572856e82444c7_Out_0_Vector4[3];
                                                float _Property_1c0b93250a8c478792eb9bbcab1dd667_Out_0_Float = _shineVerticalOffset;
                                                float _Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float;
                                                Unity_Subtract_float(_Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float, _Property_1c0b93250a8c478792eb9bbcab1dd667_Out_0_Float, _Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float);
                                                float _Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float;
                                                Unity_Absolute_float(_Subtract_679784af3b0e40a890c0b6078db21b6b_Out_2_Float, _Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float);
                                                float _Property_6ab0084071244b11b52b9b9737d68456_Out_0_Float = _shineLength;
                                                float _Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float;
                                                Unity_Subtract_float(_Absolute_628f0d6abb5c4108a73e7a445deffc2b_Out_1_Float, _Property_6ab0084071244b11b52b9b9737d68456_Out_0_Float, _Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float);
                                                float _OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float;
                                                Unity_OneMinus_float(_Subtract_e09bafcdc6744cb4b6888d9b633559d4_Out_2_Float, _OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float);
                                                float _Property_0c58e09f6e3749d1b683b4971026a036_Out_0_Float = _shineConcentration;
                                                float _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float;
                                                Unity_Power_float(_OneMinus_a0c8542fb5db4dfbbda955b8c37c204c_Out_1_Float, _Property_0c58e09f6e3749d1b683b4971026a036_Out_0_Float, _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float);
                                                float _Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float;
                                                Unity_Multiply_float_float(_Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float, _Power_9049145427ca4fdc9ccd2395544ad0f2_Out_2_Float, _Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float);
                                                float _OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float;
                                                Unity_OneMinus_float(_Split_5b4bfc8f6cca43f28b693f3288791fd2_G_2_Float, _OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float);
                                                float _Property_a82ecc5425114c2fa59012ea04e83de1_Out_0_Float = _shineBottomHeight;
                                                float _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float;
                                                Unity_Power_float(_OneMinus_aa21465c33784e20a9b43950fc070072_Out_1_Float, _Property_a82ecc5425114c2fa59012ea04e83de1_Out_0_Float, _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float);
                                                float _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float;
                                                Unity_Add_float(_Multiply_d3ac8796c9424812910ec4760f492224_Out_2_Float, _Power_1674f1740e9b4b4a839f847cd3a93b10_Out_2_Float, _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float);
                                                float _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float;
                                                Unity_Add_float(_Power_a11cf26d88294a9fab71a7bac5d6f667_Out_2_Float, _Add_e6d2636783244b74883c9ba84364ecb8_Out_2_Float, _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float);
                                                float _Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float;
                                                Unity_Step_float(_Property_df930666d03542579f9e2f0617c60c0b_Out_0_Float, _Add_e040f036af8f471bad40714bf99b6fa8_Out_2_Float, _Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float);
                                                float4 _Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4;
                                                Unity_Multiply_float4_float4(_Property_361bb62208d94436a8592182d9a62718_Out_0_Vector4, (_Step_4aa7506f6c584942933dac34c4739c8e_Out_2_Float.xxxx), _Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4);
                                                float4 _Property_c9b63e5bc4b4498fb1bc35eb07940bab_Out_0_Vector4 = IsGammaSpace() ? LinearToSRGB(BaseColor) : BaseColor;
                                                float4 _Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4;
                                                Unity_Add_float4(_Multiply_044d18ae349e4ae0bd14de2f0c0eb818_Out_2_Vector4, _Property_c9b63e5bc4b4498fb1bc35eb07940bab_Out_0_Vector4, _Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4);
                                                float4 _ScreenPosition_3ecb1ddb1ac94e6297284d6d06ef1786_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                                float _Property_5c8b26fce3e54d9ebbc0a630046017d1_Out_0_Float = _waveDistortion;
                                                float3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3;
                                                float3x3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_TangentMatrix = float3x3(IN.WorldSpaceTangent, IN.WorldSpaceBiTangent, IN.WorldSpaceNormal);
                                                float3 _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Position = IN.WorldSpacePosition;
                                                Unity_NormalFromHeight_Tangent_float(_SimpleNoise_e444ccdab5834d7e993db840e7b280ea_Out_2_Float,_Property_5c8b26fce3e54d9ebbc0a630046017d1_Out_0_Float,_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Position,_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_TangentMatrix, _NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3);
                                                float _Float_b40f001a2f51425db9113b19840e3923_Out_0_Float = 0.5;
                                                float3 _Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3;
                                                Unity_Multiply_float3_float3(_NormalFromHeight_488faae7a2944f11a0f7abdcf66975f2_Out_1_Vector3, (_Float_b40f001a2f51425db9113b19840e3923_Out_0_Float.xxx), _Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3);
                                                float2 _TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2;
                                                Unity_TilingAndOffset_float((_ScreenPosition_3ecb1ddb1ac94e6297284d6d06ef1786_Out_0_Vector4.xy), float2 (1, 1), (_Multiply_75afdbc7d44e46c2ac59d00849b7bf20_Out_2_Vector3.xy), _TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2);
                                                float3 _SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3;
                                                Unity_SceneColor_float((float4(_TilingAndOffset_0fc033cb23a0496089696dd8b6c5d4a8_Out_3_Vector2, 0.0, 1.0)), _SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3);
                                                float3 _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3;
                                                Unity_Blend_Screen_float3(_SceneColor_ac3eaffe18ef40d982c8115d39a6b8b7_Out_1_Vector3, float3(0, 0, 0), _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3, 0.7);
                                                float3 _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3;
                                                Unity_Add_float3((_Add_4f4a68de318a4d76a6caca8f5cba6417_Out_2_Vector4.xyz), _Blend_c8773bce78f34910be6656221f086c25_Out_2_Vector3, _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3);
                                                float3 _Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3;
                                                Unity_Add_float3((_InvertColors_d99a09e46fa040209a39b7008f6f0a2f_Out_1_Float.xxx), _Add_cc5fd688da644e60ab0aa9fe10bbcb97_Out_2_Vector3, _Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3);
                                                float _Property_472e66ef7f0e4be1a983e4188962d94c_Out_0_Float = innerFoamRadius;
                                                float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                                                float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                                                float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                                                float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                                                float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                                                float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                                                Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                                                float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                                                Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                                                float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                                                Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                                                float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                                                float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                                                Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                                                float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                                                Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                                                float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                                                float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                                                Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                                                float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                                                Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                                                float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                                                Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                                                float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                                                Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                                                float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                                float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                                                Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                                                float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                                                float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                                                float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                                                float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                                                float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                                                float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                                                float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                                                Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                                                float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                                                float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                                                Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                                                float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                                                float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                                                Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                                                float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                                                Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                                                float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                                                float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                                                Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                                                float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                                                Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                                                float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                                                float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                                                float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                                                float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                                                float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                                                float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                                                Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                                                float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                                                float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                                                Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                                                float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                                                float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                                                Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                                                float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                                                Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                                                float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                                                Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                                                float4 _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4;
                                                Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4);
                                                float4 _Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4;
                                                Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_472e66ef7f0e4be1a983e4188962d94c_Out_0_Float.xxxx), _Saturate_bd27b9be219648f2af7143d41753b12a_Out_1_Vector4, _Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4);
                                                float4 _OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4;
                                                Unity_OneMinus_float4(_Smoothstep_eededa960e604d05ad457399f5a08bf7_Out_3_Vector4, _OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4);
                                                float3 _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3;
                                                Unity_Add_float3(_Add_5ddf7f7e3d1b454dbd3af044942345e7_Out_2_Vector3, (_OneMinus_849335acde00457c94b1aab16d03a87c_Out_1_Vector4.xyz), _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3);
                                                float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                                                float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                                                Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                                                float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                                                Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                                                float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                                                Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                                                float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                                                Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                                                float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                                                float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                                                Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                                                float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                                                Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                                                float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                                                Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                                                surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                                                surface.Emission = _Add_09c3b86b2c004ac483d91683be4c8d68_Out_2_Vector3;
                                                surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                                                output.uv0 = input.uv0;
                                                output.TimeParameters = _TimeParameters.xyz;

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



                                                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                                                float3 unnormalizedNormalWS = input.normalWS;
                                                const float renormFactor = 1.0 / length(unnormalizedNormalWS);

                                                // use bitangent on the fly like in hdrp
                                                // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
                                                float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
                                                float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

                                                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph

                                                // to pr               eserve mikktspace compliance we use same scale renormFactor as was used on the normal.
                                                // This                is explained in section 2.2 in "surface gradient based bump mapping framework"
                                                output.WorldSpaceTangent = renormFactor * input.tangentWS.xyz;
                                                output.WorldSpaceBiTangent = renormFactor * bitang;

                                                output.WorldSpacePosition = input.positionWS;

                                                #if UNITY_UV_STARTS_AT_TOP
                                                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                #else
                                                output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                #endif

                                                output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
                                                output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                                output.uv0 = input.texCoord0;
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
                                            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

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

                                                #define _NORMALMAP 1
                                                #define _NORMAL_DROPOFF_WS 1
                                                #define ATTRIBUTES_NEED_NORMAL
                                                #define ATTRIBUTES_NEED_TANGENT
                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                #define VARYINGS_NEED_POSITION_WS
                                                #define VARYINGS_NEED_TEXCOORD0
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
                                                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
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
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                    #endif
                                                };
                                                struct Varyings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float3 positionWS;
                                                     float4 texCoord0;
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
                                                     float3 WorldSpacePosition;
                                                     float4 uv0;
                                                     float3 TimeParameters;
                                                };
                                                struct VertexDescriptionInputs
                                                {
                                                     float3 ObjectSpaceNormal;
                                                     float3 ObjectSpaceTangent;
                                                     float3 ObjectSpacePosition;
                                                     float4 uv0;
                                                     float3 TimeParameters;
                                                };
                                                struct PackedVaryings
                                                {
                                                     float4 positionCS : SV_POSITION;
                                                     float4 texCoord0 : INTERP0;
                                                     float3 positionWS : INTERP1;
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
                                                    output.positionWS.xyz = input.positionWS;
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
                                                    output.positionWS = input.positionWS.xyz;
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
                                                float radiusGradient;
                                                float4 BaseColor;
                                                float innerFoamRadius;
                                                float _upperHalfRadius;
                                                float _bottomHalfRadius;
                                                float _watergap;
                                                float _flowSpeedDirection;
                                                float _flowVariation;
                                                float4 _shineColor;
                                                float _shineConcentration;
                                                float _shineDiminish;
                                                float _shineVerticalOffset;
                                                float _shineScale;
                                                float _shineLength;
                                                float _shineFoamMiddle;
                                                float _shineBottomHeight;
                                                float _waveEdgeWobbleSpeed;
                                                float _waveEdgeWobbleAmount;
                                                float _waveEdgeWobbleDistance;
                                                float _waveEdgeThickness;
                                                float _waveVerticalStrength;
                                                float _waveSpeed;
                                                float _waveThickness;
                                                float _waveDistortion;
                                                float _waveNoiseScale;
                                                CBUFFER_END


                                                    // Object and Global properties
                                                    float4 _NekoLegendsWaterfallObjectInteraction;
                                                    float _radius;

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

                                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                    {
                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                    }

                                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                    {
                                                        Out = A * B;
                                                    }

                                                    void Unity_Preview_float(float In, out float Out)
                                                    {
                                                        Out = In;
                                                    }

                                                    void Unity_Add_float(float A, float B, out float Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Sine_float(float In, out float Out)
                                                    {
                                                        Out = sin(In);
                                                    }

                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                    {
                                                        Out = step(Edge, In);
                                                    }

                                                    void Unity_OneMinus_float(float In, out float Out)
                                                    {
                                                        Out = 1 - In;
                                                    }

                                                    void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                    {
                                                        float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                                        float4 result2 = 2.0 * Base * Blend;
                                                        float4 zeroOrOne = step(Base, 0.5);
                                                        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                                        Out = lerp(Base, Out, Opacity);
                                                    }

                                                    void Unity_Distance_float3(float3 A, float3 B, out float Out)
                                                    {
                                                        Out = distance(A, B);
                                                    }

                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                    {
                                                        Out = A - B;
                                                    }

                                                    void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                                    {
                                                        Out = A > B ? 1 : 0;
                                                    }

                                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                    {
                                                        Out = Predicate ? True : False;
                                                    }

                                                    void Unity_Lerp_float(float A, float B, float T, out float Out)
                                                    {
                                                        Out = lerp(A, B, T);
                                                    }

                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A + B;
                                                    }

                                                    void Unity_Saturate_float4(float4 In, out float4 Out)
                                                    {
                                                        Out = saturate(In);
                                                    }

                                                    void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
                                                    {
                                                        Out = smoothstep(Edge1, Edge2, In);
                                                    }

                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                    {
                                                        Out = A * B;
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
                                                        float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                                                        float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                                                        float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                                                        float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                                                        float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                                                        float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                                                        float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                                                        Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                                                        float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                                                        Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                                                        float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                                                        Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                                                        description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                                                        float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                                                        float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                                                        float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                                                        float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                                                        float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                                                        float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                                                        float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                                                        Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                                                        float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                                                        float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                                                        float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                                                        Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                                                        float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                                                        float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                                                        Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                                                        float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                                                        Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                                                        float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                                                        float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                                                        Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                                                        float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                                                        Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                                                        float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                                                        Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                                                        float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                                                        Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                                                        float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                                                        Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                                                        float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                                                        Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                                                        float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                                                        float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                                                        float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                                                        Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                                                        float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                                                        Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                                                        float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                                                        Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                                                        float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                                                        float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                                                        Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                                                        float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                                                        Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                                                        float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                                                        float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                                                        Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                                                        float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                                                        Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                                                        float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                                                        Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                                                        float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                                                        Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                                                        float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                                        float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                                                        Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                                                        float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                                                        float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                        float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                                                        float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                                                        float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                                                        float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                                                        float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                                                        float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                                                        Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                                                        float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                                                        float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                                                        Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                                                        float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                                                        float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                                                        Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                                                        float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                        float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                                                        Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                                                        float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                                                        float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                                                        Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                                                        float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                                                        Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                                                        float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                                                        float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                                                        Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                                                        float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                                                        float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                                                        Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                                                        float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                                                        float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                                                        Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                                                        float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                                                        Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                                                        float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                                                        Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                                                        float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                                                        Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                                                        float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                                                        Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                                                        float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                                                        Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                                                        surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                                                        output.uv0 = input.uv0;
                                                        output.TimeParameters = _TimeParameters.xyz;

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







                                                        output.WorldSpacePosition = input.positionWS;

                                                        #if UNITY_UV_STARTS_AT_TOP
                                                        #else
                                                        #endif


                                                        output.uv0 = input.texCoord0;
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

                                                        #define _NORMALMAP 1
                                                        #define _NORMAL_DROPOFF_WS 1
                                                        #define ATTRIBUTES_NEED_NORMAL
                                                        #define ATTRIBUTES_NEED_TANGENT
                                                        #define ATTRIBUTES_NEED_TEXCOORD0
                                                        #define VARYINGS_NEED_POSITION_WS
                                                        #define VARYINGS_NEED_TEXCOORD0
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
                                                        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
                                                        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                                        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
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
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                             uint instanceID : INSTANCEID_SEMANTIC;
                                                            #endif
                                                        };
                                                        struct Varyings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float3 positionWS;
                                                             float4 texCoord0;
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
                                                             float3 WorldSpacePosition;
                                                             float4 uv0;
                                                             float3 TimeParameters;
                                                        };
                                                        struct VertexDescriptionInputs
                                                        {
                                                             float3 ObjectSpaceNormal;
                                                             float3 ObjectSpaceTangent;
                                                             float3 ObjectSpacePosition;
                                                             float4 uv0;
                                                             float3 TimeParameters;
                                                        };
                                                        struct PackedVaryings
                                                        {
                                                             float4 positionCS : SV_POSITION;
                                                             float4 texCoord0 : INTERP0;
                                                             float3 positionWS : INTERP1;
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
                                                            output.positionWS.xyz = input.positionWS;
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
                                                            output.positionWS = input.positionWS.xyz;
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
                                                        float radiusGradient;
                                                        float4 BaseColor;
                                                        float innerFoamRadius;
                                                        float _upperHalfRadius;
                                                        float _bottomHalfRadius;
                                                        float _watergap;
                                                        float _flowSpeedDirection;
                                                        float _flowVariation;
                                                        float4 _shineColor;
                                                        float _shineConcentration;
                                                        float _shineDiminish;
                                                        float _shineVerticalOffset;
                                                        float _shineScale;
                                                        float _shineLength;
                                                        float _shineFoamMiddle;
                                                        float _shineBottomHeight;
                                                        float _waveEdgeWobbleSpeed;
                                                        float _waveEdgeWobbleAmount;
                                                        float _waveEdgeWobbleDistance;
                                                        float _waveEdgeThickness;
                                                        float _waveVerticalStrength;
                                                        float _waveSpeed;
                                                        float _waveThickness;
                                                        float _waveDistortion;
                                                        float _waveNoiseScale;
                                                        CBUFFER_END


                                                            // Object and Global properties
                                                            float4 _NekoLegendsWaterfallObjectInteraction;
                                                            float _radius;

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

                                                            void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                            {
                                                                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                            }

                                                            void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                            {
                                                                Out = A * B;
                                                            }

                                                            void Unity_Preview_float(float In, out float Out)
                                                            {
                                                                Out = In;
                                                            }

                                                            void Unity_Add_float(float A, float B, out float Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Sine_float(float In, out float Out)
                                                            {
                                                                Out = sin(In);
                                                            }

                                                            void Unity_Step_float(float Edge, float In, out float Out)
                                                            {
                                                                Out = step(Edge, In);
                                                            }

                                                            void Unity_OneMinus_float(float In, out float Out)
                                                            {
                                                                Out = 1 - In;
                                                            }

                                                            void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                            {
                                                                float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                                                float4 result2 = 2.0 * Base * Blend;
                                                                float4 zeroOrOne = step(Base, 0.5);
                                                                Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                                                Out = lerp(Base, Out, Opacity);
                                                            }

                                                            void Unity_Distance_float3(float3 A, float3 B, out float Out)
                                                            {
                                                                Out = distance(A, B);
                                                            }

                                                            void Unity_Subtract_float(float A, float B, out float Out)
                                                            {
                                                                Out = A - B;
                                                            }

                                                            void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                                            {
                                                                Out = A > B ? 1 : 0;
                                                            }

                                                            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                            {
                                                                Out = Predicate ? True : False;
                                                            }

                                                            void Unity_Lerp_float(float A, float B, float T, out float Out)
                                                            {
                                                                Out = lerp(A, B, T);
                                                            }

                                                            void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                            {
                                                                Out = A + B;
                                                            }

                                                            void Unity_Saturate_float4(float4 In, out float4 Out)
                                                            {
                                                                Out = saturate(In);
                                                            }

                                                            void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
                                                            {
                                                                Out = smoothstep(Edge1, Edge2, In);
                                                            }

                                                            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                            {
                                                                Out = A * B;
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
                                                                float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                                                                float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                                                                float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                                                                Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                                                                float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                                                                float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                                                                Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                                                                float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                                                                float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                                                                Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                                                                float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                                                                Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                                                                float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                                                                Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                                                                description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                                                                float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                                                                float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                                                                float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                                                                float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                                                                float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                                                                float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                                                                float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                                                                Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                                                                float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                                                                float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                                                                Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                                                                float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                                                                Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                                                                float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                                                                float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                                                                Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                                                                float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                                                                Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                                                                float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                                                                float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                                                                Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                                                                float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                                                                Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                                                                float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                                                                Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                                                                float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                                                                Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                                                                float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                                                                Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                                                                float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                                                                Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                                                                float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                                                                float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                                                                float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                                                                float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                                                                float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                                                                float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                                                                float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                                                                Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                                                                float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                                                                Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                                                                float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                                                                Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                                                                float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                                                                float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                                                                Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                                                                float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                                                                Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                                                                float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                                                                float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                                                                Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                                                                float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                                                                Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                                                                float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                                                                Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                                                                float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                                                                Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                                                                float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                                                float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                                                                Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                                                                float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                                                                float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                                                                float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                                float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                                                                float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                                                                float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                                                                float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                                                                float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                                                                float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                                                                Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                                                                float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                                                                float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                                                                Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                                                                float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                                                                float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                                                                Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                                                                float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                                float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                                                                Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                                                                float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                                                                float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                                                                Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                                                                float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                                                                Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                                                                float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                                                                float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                                                                float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                                                                float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                                                                float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                                                                float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                                                                float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                                                                Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                                                                float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                                                                float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                                                                Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                                                                float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                                                                float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                                                                Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                                                                float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                                                                Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                                                                float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                                                                Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                                                                float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                                                                Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                                                                float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                                                                Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                                                                float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                                                                Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                                                                surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                                                                output.uv0 = input.uv0;
                                                                output.TimeParameters = _TimeParameters.xyz;

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







                                                                output.WorldSpacePosition = input.positionWS;

                                                                #if UNITY_UV_STARTS_AT_TOP
                                                                #else
                                                                #endif


                                                                output.uv0 = input.texCoord0;
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
                                                                // Name: <None>
                                                                Tags
                                                                {
                                                                    "LightMode" = "Universal2D"
                                                                }

                                                                // Render State
                                                                Cull Off
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
                                                                #pragma vertex vert
                                                                #pragma fragment frag

                                                                // Keywords
                                                                // PassKeywords: <None>
                                                                // GraphKeywords: <None>

                                                                // Defines

                                                                #define _NORMALMAP 1
                                                                #define _NORMAL_DROPOFF_WS 1
                                                                #define ATTRIBUTES_NEED_NORMAL
                                                                #define ATTRIBUTES_NEED_TANGENT
                                                                #define ATTRIBUTES_NEED_TEXCOORD0
                                                                #define VARYINGS_NEED_POSITION_WS
                                                                #define VARYINGS_NEED_TEXCOORD0
                                                                #define FEATURES_GRAPH_VERTEX
                                                                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                                #define SHADERPASS SHADERPASS_2D


                                                                // custom interpolator pre-include
                                                                /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                                // Includes
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                                                #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
                                                                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
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
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                     uint instanceID : INSTANCEID_SEMANTIC;
                                                                    #endif
                                                                };
                                                                struct Varyings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float3 positionWS;
                                                                     float4 texCoord0;
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
                                                                     float3 WorldSpacePosition;
                                                                     float4 uv0;
                                                                     float3 TimeParameters;
                                                                };
                                                                struct VertexDescriptionInputs
                                                                {
                                                                     float3 ObjectSpaceNormal;
                                                                     float3 ObjectSpaceTangent;
                                                                     float3 ObjectSpacePosition;
                                                                     float4 uv0;
                                                                     float3 TimeParameters;
                                                                };
                                                                struct PackedVaryings
                                                                {
                                                                     float4 positionCS : SV_POSITION;
                                                                     float4 texCoord0 : INTERP0;
                                                                     float3 positionWS : INTERP1;
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
                                                                    output.positionWS.xyz = input.positionWS;
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
                                                                    output.positionWS = input.positionWS.xyz;
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
                                                                float radiusGradient;
                                                                float4 BaseColor;
                                                                float innerFoamRadius;
                                                                float _upperHalfRadius;
                                                                float _bottomHalfRadius;
                                                                float _watergap;
                                                                float _flowSpeedDirection;
                                                                float _flowVariation;
                                                                float4 _shineColor;
                                                                float _shineConcentration;
                                                                float _shineDiminish;
                                                                float _shineVerticalOffset;
                                                                float _shineScale;
                                                                float _shineLength;
                                                                float _shineFoamMiddle;
                                                                float _shineBottomHeight;
                                                                float _waveEdgeWobbleSpeed;
                                                                float _waveEdgeWobbleAmount;
                                                                float _waveEdgeWobbleDistance;
                                                                float _waveEdgeThickness;
                                                                float _waveVerticalStrength;
                                                                float _waveSpeed;
                                                                float _waveThickness;
                                                                float _waveDistortion;
                                                                float _waveNoiseScale;
                                                                CBUFFER_END


                                                                    // Object and Global properties
                                                                    float4 _NekoLegendsWaterfallObjectInteraction;
                                                                    float _radius;

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

                                                                    void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                                                                    {
                                                                        Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                    }

                                                                    void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
                                                                    {
                                                                        Out = A * B;
                                                                    }

                                                                    void Unity_Preview_float(float In, out float Out)
                                                                    {
                                                                        Out = In;
                                                                    }

                                                                    void Unity_Add_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Sine_float(float In, out float Out)
                                                                    {
                                                                        Out = sin(In);
                                                                    }

                                                                    void Unity_Step_float(float Edge, float In, out float Out)
                                                                    {
                                                                        Out = step(Edge, In);
                                                                    }

                                                                    void Unity_OneMinus_float(float In, out float Out)
                                                                    {
                                                                        Out = 1 - In;
                                                                    }

                                                                    void Unity_Blend_Overlay_float4(float4 Base, float4 Blend, out float4 Out, float Opacity)
                                                                    {
                                                                        float4 result1 = 1.0 - 2.0 * (1.0 - Base) * (1.0 - Blend);
                                                                        float4 result2 = 2.0 * Base * Blend;
                                                                        float4 zeroOrOne = step(Base, 0.5);
                                                                        Out = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                                                                        Out = lerp(Base, Out, Opacity);
                                                                    }

                                                                    void Unity_Distance_float3(float3 A, float3 B, out float Out)
                                                                    {
                                                                        Out = distance(A, B);
                                                                    }

                                                                    void Unity_Subtract_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A - B;
                                                                    }

                                                                    void Unity_Comparison_Greater_float(float A, float B, out float Out)
                                                                    {
                                                                        Out = A > B ? 1 : 0;
                                                                    }

                                                                    void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                                                                    {
                                                                        Out = Predicate ? True : False;
                                                                    }

                                                                    void Unity_Lerp_float(float A, float B, float T, out float Out)
                                                                    {
                                                                        Out = lerp(A, B, T);
                                                                    }

                                                                    void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A + B;
                                                                    }

                                                                    void Unity_Saturate_float4(float4 In, out float4 Out)
                                                                    {
                                                                        Out = saturate(In);
                                                                    }

                                                                    void Unity_Smoothstep_float4(float4 Edge1, float4 Edge2, float4 In, out float4 Out)
                                                                    {
                                                                        Out = smoothstep(Edge1, Edge2, In);
                                                                    }

                                                                    void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                                    {
                                                                        Out = A * B;
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
                                                                        float _Property_e3ae391960d449e581641ca85391197a_Out_0_Float = _waveSpeed;
                                                                        float _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float;
                                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_e3ae391960d449e581641ca85391197a_Out_0_Float, _Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float);
                                                                        float2 _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2;
                                                                        Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_4bf2914c1af04fc5adf274b3b1637056_Out_2_Float.xx), _TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2);
                                                                        float _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float = _waveNoiseScale;
                                                                        float _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float;
                                                                        Unity_GradientNoise_LegacyMod_float(_TilingAndOffset_77306a2b16764d5ead259b1a89ac0948_Out_3_Vector2, _Property_73e665ee3bb440c298fba901fc7348a7_Out_0_Float, _GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float);
                                                                        float _Property_69348493368f4748ab9716568fc9b576_Out_0_Float = _waveVerticalStrength;
                                                                        float _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float;
                                                                        Unity_Multiply_float_float(_GradientNoise_a1e3983b9ef34fe9b6f284d0abcc5e1d_Out_2_Float, _Property_69348493368f4748ab9716568fc9b576_Out_0_Float, _Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float);
                                                                        float _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float;
                                                                        Unity_Remap_float(_Multiply_816e039920284d8dac620c69acb7c72b_Out_2_Float, float2 (-1, 1), float2 (0.7, 0.83), _Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float);
                                                                        float3 _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
                                                                        Unity_Multiply_float3_float3((_Remap_eaf4b9853b5645cdaab9fad581eeeb85_Out_3_Float.xxx), IN.ObjectSpacePosition, _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3);
                                                                        description.Position = _Multiply_808e3c022bcd4db789fc6c3da946c42d_Out_2_Vector3;
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
                                                                        float _Float_128416cd201845348d2a6b0a7e068969_Out_0_Float = 0.04;
                                                                        float4 _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4 = IN.uv0;
                                                                        float _Split_e4f63517484147e1a9b635590ed33050_R_1_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[0];
                                                                        float _Split_e4f63517484147e1a9b635590ed33050_G_2_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[1];
                                                                        float _Split_e4f63517484147e1a9b635590ed33050_B_3_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[2];
                                                                        float _Split_e4f63517484147e1a9b635590ed33050_A_4_Float = _UV_4c2e9a66619d438fb5a1a9ceefebd924_Out_0_Vector4[3];
                                                                        float _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float;
                                                                        Unity_Preview_float(_Split_e4f63517484147e1a9b635590ed33050_R_1_Float, _Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float);
                                                                        float _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float = _waveEdgeWobbleSpeed;
                                                                        float _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float;
                                                                        Unity_Multiply_float_float(IN.TimeParameters.x, _Property_cbba2ce7e054409f99e191c954d2f456_Out_0_Float, _Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float);
                                                                        float _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float;
                                                                        Unity_Add_float(_Multiply_8424aeae9be84394b2244eb2a8458c01_Out_2_Float, _Split_e4f63517484147e1a9b635590ed33050_G_2_Float, _Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float);
                                                                        float _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float = _waveEdgeWobbleAmount;
                                                                        float _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Add_0066bc0019cb4866903a9d3cbec46a83_Out_2_Float, _Property_120f196bc719487c946ca7154b25cc81_Out_0_Float, _Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float);
                                                                        float _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float;
                                                                        Unity_Sine_float(_Multiply_ae347a5732154a049b530f6608e95d68_Out_2_Float, _Sine_7315193b730b45d795c932dbd634330e_Out_1_Float);
                                                                        float _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float = _waveEdgeWobbleDistance;
                                                                        float _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Sine_7315193b730b45d795c932dbd634330e_Out_1_Float, _Property_1217440d71c64a2b85e3be90e3342d72_Out_0_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float);
                                                                        float _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float;
                                                                        Unity_Add_float(_Preview_62d5ea3aaee345f0858cdd7569e1fe3a_Out_1_Float, _Multiply_ff8efed928ed4a0da73c4da8d835b78d_Out_2_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float);
                                                                        float _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float;
                                                                        Unity_Step_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _Step_47f977ccea9a40a28dccad2444744091_Out_2_Float);
                                                                        float _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float;
                                                                        Unity_OneMinus_float(_Float_128416cd201845348d2a6b0a7e068969_Out_0_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float);
                                                                        float _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float;
                                                                        Unity_Step_float(_Add_198e19ac48ed43c4ad688a8922841e2f_Out_2_Float, _OneMinus_7a3e63ab34234af88a5b1f73932e70f5_Out_1_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float);
                                                                        float _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Step_47f977ccea9a40a28dccad2444744091_Out_2_Float, _Step_6f7135bb6d374acd89f86704f9bf90ea_Out_2_Float, _Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float);
                                                                        float _Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float = radiusGradient;
                                                                        float4 _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4 = IN.uv0;
                                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[0];
                                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[1];
                                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_B_3_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[2];
                                                                        float _Split_b010f9b4e8274ebe975096deef20baa1_A_4_Float = _UV_124e2d52bfec4129b4497c7cb7102e74_Out_0_Vector4[3];
                                                                        float _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float;
                                                                        Unity_Preview_float(_Split_b010f9b4e8274ebe975096deef20baa1_R_1_Float, _Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float);
                                                                        float _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float;
                                                                        Unity_Multiply_float_float(IN.TimeParameters.x, 1, _Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float);
                                                                        float _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float;
                                                                        Unity_Add_float(_Multiply_9c5c1c9c241d4ef49b9ea2b74ff33dfb_Out_2_Float, _Split_b010f9b4e8274ebe975096deef20baa1_G_2_Float, _Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float);
                                                                        float _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float = _waveThickness;
                                                                        float _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Add_e248b76ebab34b35b1bba59fa3585b86_Out_2_Float, _Property_94d9bec6b04847948da383afd37eb8af_Out_0_Float, _Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float);
                                                                        float _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float;
                                                                        Unity_Sine_float(_Multiply_f6dac7f3bb8e438dadc0fbe48b6ef87a_Out_2_Float, _Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float);
                                                                        float _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float = _waveDistortion;
                                                                        float _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Sine_09b9c3201ebe46e39d66e658d06aa4c2_Out_1_Float, _Property_3d3d72473e6a431795c75d381f6165ec_Out_0_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float);
                                                                        float _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float;
                                                                        Unity_Add_float(_Preview_5064183b0e144d2d804c6364d8e1903b_Out_1_Float, _Multiply_41f79356e40b4ac2b8a30a299813fb3a_Out_2_Float, _Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float);
                                                                        float _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float;
                                                                        Unity_OneMinus_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float);
                                                                        float _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float;
                                                                        Unity_Multiply_float_float(_Add_2c9989546d5d46ecacf3ce667e68a4ca_Out_2_Float, _OneMinus_d32cf8fdda62429ab633fc5a3682b7fc_Out_1_Float, _Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float);
                                                                        float4 Color_df82deba2bed4aa2a516f786ac9b7593 = IsGammaSpace() ? float4(1, 1, 1, 0) : float4(SRGBToLinear(float3(1, 1, 1)), 0);
                                                                        float4 _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4;
                                                                        Unity_Blend_Overlay_float4((_Multiply_8a23b518b6f44ba7a201bdb6a35fd06c_Out_2_Float.xxxx), Color_df82deba2bed4aa2a516f786ac9b7593, _Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, 1);
                                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float = IN.WorldSpacePosition[0];
                                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_G_2_Float = IN.WorldSpacePosition[1];
                                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float = IN.WorldSpacePosition[2];
                                                                        float _Split_52b18d9b3acf41999841d6f5712ff82a_A_4_Float = 0;
                                                                        float3 _Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3 = float3(_Split_52b18d9b3acf41999841d6f5712ff82a_R_1_Float, 1, _Split_52b18d9b3acf41999841d6f5712ff82a_B_3_Float);
                                                                        float4 _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                                        float _Split_a603836019be44aab4bf4467c40464e3_R_1_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[0];
                                                                        float _Split_a603836019be44aab4bf4467c40464e3_G_2_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[1];
                                                                        float _Split_a603836019be44aab4bf4467c40464e3_B_3_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[2];
                                                                        float _Split_a603836019be44aab4bf4467c40464e3_A_4_Float = _Property_e523cb6978a045b99783482b37d473a2_Out_0_Vector4[3];
                                                                        float3 _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3 = float3(_Split_a603836019be44aab4bf4467c40464e3_R_1_Float, 1, _Split_a603836019be44aab4bf4467c40464e3_B_3_Float);
                                                                        float _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float;
                                                                        Unity_Distance_float3(_Vector3_5472be57c16045de8623801aa21eb18c_Out_0_Vector3, _Vector3_1cff83a329904d55b452f69014f5f844_Out_0_Vector3, _Distance_ac10a276b0044673a096188f4843c791_Out_2_Float);
                                                                        float _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float = _bottomHalfRadius;
                                                                        float _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float;
                                                                        Unity_Subtract_float(_Distance_ac10a276b0044673a096188f4843c791_Out_2_Float, _Property_2c82dfc058084375a3eb4923f95a62f2_Out_0_Float, _Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float);
                                                                        float _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float = _radius;
                                                                        float _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float;
                                                                        Unity_Subtract_float(_Subtract_9eba0f0c9379437889bd858fcede8531_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float);
                                                                        float4 _Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                                        float _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float;
                                                                        Unity_Distance_float3((_Property_eb42d0faa46e4412ab824d10dd019a4e_Out_0_Vector4.xyz), IN.WorldSpacePosition, _Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float);
                                                                        float _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float = _upperHalfRadius;
                                                                        float _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float;
                                                                        Unity_Subtract_float(_Distance_615338338f504cddbab234ef2da4d0f0_Out_2_Float, _Property_dcfb8fffcdea4684be7d8e8dcd191730_Out_0_Float, _Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float);
                                                                        float _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float;
                                                                        Unity_Subtract_float(_Subtract_4469254bce8e4fd08a4c21790f03bce1_Out_2_Float, _Property_b67dadaa82c1403e854ca754c2d7dc80_Out_0_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float);
                                                                        float4 _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4 = _NekoLegendsWaterfallObjectInteraction;
                                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_R_1_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[0];
                                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[1];
                                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_B_3_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[2];
                                                                        float _Split_dfac96edc0f94ee783bcb8b84a042bc2_A_4_Float = _Property_3ce45c846a4a40ec98ab21d0b346ae69_Out_0_Vector4[3];
                                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_R_1_Float = IN.WorldSpacePosition[0];
                                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float = IN.WorldSpacePosition[1];
                                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_B_3_Float = IN.WorldSpacePosition[2];
                                                                        float _Split_b35bb601065144cd9ec52a0de52fe075_A_4_Float = 0;
                                                                        float _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float;
                                                                        Unity_Subtract_float(_Split_dfac96edc0f94ee783bcb8b84a042bc2_G_2_Float, _Split_b35bb601065144cd9ec52a0de52fe075_G_2_Float, _Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float);
                                                                        float _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float = 0;
                                                                        float _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean;
                                                                        Unity_Comparison_Greater_float(_Subtract_9cdd6511dbc34118819473610cf38512_Out_2_Float, _Float_f36bd4f6f1504416aca25479d3c6018c_Out_0_Float, _Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean);
                                                                        float _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float = _watergap;
                                                                        float _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float;
                                                                        Unity_Branch_float(_Comparison_5b318b02debd44c2b48e1019857c11e8_Out_2_Boolean, _Property_0f96c30e68cf43cf8cd32f8959a04863_Out_0_Float, 1, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float);
                                                                        float _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float;
                                                                        Unity_Lerp_float(_Subtract_f1fe620943784b34a98193156f56bd83_Out_2_Float, _Subtract_2d7c90f3743747e8b65b2920952d2a60_Out_2_Float, _Branch_329c0c00a8024cfdac99500f3c36387c_Out_3_Float, _Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float);
                                                                        float4 _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4;
                                                                        Unity_Add_float4(_Blend_fda6f2d6d5a44db4a05a969e0e7c74c2_Out_2_Vector4, (_Lerp_a1fc5a1b55e9470fa105f84658aa7c7e_Out_3_Float.xxxx), _Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4);
                                                                        float4 _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4;
                                                                        Unity_Saturate_float4(_Add_36fe7eb92163434abd3a121ebb8b2190_Out_2_Vector4, _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4);
                                                                        float4 _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4;
                                                                        Unity_Smoothstep_float4(float4(0, 0, 0, 0), (_Property_83e4d2459cdb47f5bf6936f061885a3e_Out_0_Float.xxxx), _Saturate_02a95e6371e14a368cacb5c7a4b4633a_Out_1_Vector4, _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4);
                                                                        float4 _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4;
                                                                        Unity_Multiply_float4_float4((_Multiply_b568ab67998542ab95dbf966e4e1c5f5_Out_2_Float.xxxx), _Smoothstep_916e764d72614f07ba2071f83d4b597e_Out_3_Vector4, _Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4);
                                                                        surface.BaseColor = IsGammaSpace() ? float3(0, 0, 0) : SRGBToLinear(float3(0, 0, 0));
                                                                        surface.Alpha = (_Multiply_c926d51bfa8d4a61b20f1a882788a119_Out_2_Vector4).x;
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
                                                                        output.uv0 = input.uv0;
                                                                        output.TimeParameters = _TimeParameters.xyz;

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







                                                                        output.WorldSpacePosition = input.positionWS;

                                                                        #if UNITY_UV_STARTS_AT_TOP
                                                                        #else
                                                                        #endif


                                                                        output.uv0 = input.texCoord0;
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
                                                                    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                                    // --------------------------------------------------
                                                                    // Visual Effect Vertex Invocations
                                                                    #ifdef HAVE_VFX_MODIFICATION
                                                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
                                                                    #endif

                                                                    ENDHLSL
                                                                    }
    }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                        CustomEditorForRenderPipeline "NekoLegends.WaterfallStylizedInspector" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
                                                                        FallBack "Hidden/Shader Graph/FallbackError"
}