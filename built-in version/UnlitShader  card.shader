Shader "Unlit/UnlitShader card"
{
    Properties
    {
        _MaskA ("mask a", 2D) = "white" {}
        _MaskB ("mask b", 2D) = "white" {}
        _LUT ("LUT", 2D) = "white" {}
        RParam("R param", Vector) = (1, 0, 0, 1)
        GParam("G param", Vector) = (1, 0, 0, 1)
        BParam("B param", Vector) = (1, 0, 0, 1)
        _ClipValue("AlphaClipThreshold", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MaskA;
            sampler2D _MaskB;
            sampler2D _LUT;
            float4 RParam;
            float4 GParam;
            float4 BParam;
            float _ClipValue;
                      

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MaskA);
                o.normal = v.normal;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 Holo(half2 uv, float3 normal, half mask, half4 param)
            {
                half viewAngle=dot(_WorldSpaceCameraPos.xyz, normal);
                float2 calc_uv = float2(uv.y*param.x + param.y+viewAngle, param.z);
                return tex2D(_LUT, calc_uv) * mask * param.w;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                half4 maskB = tex2D(_MaskB, i.uv);
                clip(maskB.a - _ClipValue);
                
                half4 maskA = tex2D(_MaskA, i.uv);
                
                half4 holoR = Holo(i.uv, i.normal, maskA.r * maskB.r, RParam);
                half4 holoG = Holo(i.uv, i.normal, maskA.g, GParam);
                half4 holoB = Holo(i.uv, i.normal, maskA.b, BParam);
                
                fixed4 col = half4((holoR+holoG+holoB).rgb, maskB.a);
                return col;
            }
            ENDCG
        }
    }
}
