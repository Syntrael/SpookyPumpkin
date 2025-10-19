// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MarchingCubesGPUProject/DrawStructuredBuffer2" 
{
	Properties
    {
		_Color ("Color", Color) = (1, 1, 1, 1)

		_Shininess ("Shininess", Float) = 10 //Shininess
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
    }
	SubShader 
	{
		Pass 
		{
            Tags {"LightMode"="ForwardBase"}
			Cull back
			
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma multi_compile _ VERTEXLIGHT_ON
			#include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc" // for _LightColor0
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag


			//uniform float4 _LightColor0; //From UnityCG

            uniform float4 _Color; //Use the above variables in here
            //uniform float4 _SpecColor;
            uniform float _Shininess;


			struct Vert
			{
				float4 position;
				float3 normal;
			};

			uniform StructuredBuffer<Vert> _Buffer;
            uniform float4x4 _ModelMatrix;
			
            struct v2f 
			{
				fixed4 diff : COLOR0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 coord : TEXCOORD0;                
			};
            

            v2f vert(uint id : SV_VertexID)
			{
				Vert vert = _Buffer[id];

				v2f OUT;
                
                float4 pos = mul(_ModelMatrix, float4(vert.position.xyz, 1));
				OUT.coord = vert.position.xyz;// *_Tiling;//pos.xyz *_Tiling;
                OUT.vertex = mul(UNITY_MATRIX_VP, pos);
				//float4 pos = UnityObjectToClipPos(float4(vert.position.xyz, 1));

                half3 worldNormal = UnityObjectToWorldNormal(vert.normal);
				//half3 worldNormal = mul(_ModelMatrix, float4(vert.normal.xyz, 1));
				
                OUT.normal = worldNormal;
				
                

                half nl = max(0, dot(_WorldSpaceLightPos0.xyz, worldNormal));
				OUT.diff = _Color * nl * _LightColor0; //factor in the light color

				return OUT;
			}

			float4 frag(v2f IN) : SV_Target
			{
				//return IN.diff; //float4(IN.normal, 1);


				float3 normalDirection = normalize(IN.normal);
                float3 viewDirection = normalize(_WorldSpaceCameraPos - IN.vertex.xyz);

                float3 vert2LightSource = _WorldSpaceLightPos0.xyz - IN.vertex.xyz;
                float oneOverDistance = 1.0 / length(vert2LightSource);
                float attenuation = lerp(1.0, oneOverDistance, _WorldSpaceLightPos0.w); //Optimization for spot lights. This isn't needed if you're just getting started.
                float3 lightDirection = _WorldSpaceLightPos0.xyz - IN.vertex.xyz * _WorldSpaceLightPos0.w;

                float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb; //Ambient component
                float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection)); //Diffuse component
                float3 specularReflection;
                if (dot(IN.normal, lightDirection) < 0.0) //Light on the wrong side - no specular
                {
                    specularReflection = float3(0.0, 0.0, 0.0);
                }
                else
                {
                    //Specular component
                    specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
                }

                float3 color = (ambientLighting + diffuseReflection) + specularReflection; //Texture is not applient on specularReflection
                //return float4(IN.normal.xyz, 1.0);//float4(color, 1.0);
				return float4(color, 1.0);
			}
			ENDCG
		}
	}
}