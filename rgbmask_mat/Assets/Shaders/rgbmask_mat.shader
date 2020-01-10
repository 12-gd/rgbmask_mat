Shader "Custom/Standard RGBmask" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_ColorMask("MASK (RGB)", 2D) = "white" {}
		_ColorR("Rmask Color", Color) = (1,1,1,1)
		_ColorG("Gmask Color", Color) = (1,1,1,1)
		_ColorB("Bmask Color", Color) = (1,1,1,1)

		_NormalTex("Normal map", 2D) = "bump" {}
		_Npower1("Normap map1 power", Range(0,15)) = 0.5

		_DetailNormal("Detail Normal map (RGB)", 2D) = "bump" {}
		_Ndetpower1("Detail Normap map1 power", Range(0,5)) = 0.5

	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }
		Cull Off
		LOD 200
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NormalTex;
		sampler2D _DetailNormal;
		sampler2D _ColorMask;

	struct Input {
		float2 uv_MainTex;
		float2 uv2_DetailNormal;
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;
	
	fixed4 _ColorR;
	fixed4 _ColorG;
	fixed4 _ColorB;

	half _Npower1;
	half _Ndetpower1;

	// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
	// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
	// #pragma instancing_options assumeuniformscaling
	UNITY_INSTANCING_CBUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf(Input IN, inout SurfaceOutputStandard o) {
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
		
		//mask
		fixed4 m = tex2D(_ColorMask,IN.uv_MainTex);//o.Albedo;

		o.Albedo = m.r * (c.rgb*(_ColorR+((_ColorR)))) + (1 - m.r) * c.rgb;
		o.Albedo = m.g * (c.rgb*(_ColorG+((_ColorG)))) + (1 - m.g) * o.Albedo;
		o.Albedo = m.b * (c.rgb*(_ColorB+((_ColorB)))) + (1 - m.b) * o.Albedo;
		
		float mm = 1-(m.r+m.g+m.b);

		o.Albedo = mm * (c.rgb*_Color) + (1 - mm) * o.Albedo;

		fixed3 normal = UnpackScaleNormal(tex2D(_NormalTex, IN.uv_MainTex), _Npower1);
		fixed3 detnorm = UnpackScaleNormal(tex2D(_DetailNormal, IN.uv2_DetailNormal), _Ndetpower1);
		o.Normal = float3(normal.x + detnorm.x, normal.y + detnorm.y, normal.z + detnorm.z);

		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;

		o.Alpha = c.a;
	}
	ENDCG
	}
		FallBack "Diffuse"
}
