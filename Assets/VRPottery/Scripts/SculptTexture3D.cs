using System;
using System.Collections;
using System.Collections.Generic;
using System.Xml.Linq;
using MarchingCubesGPUProject;
using UnityEngine;

[RequireComponent(typeof(CreateRenderTexture))]
[RequireComponent(typeof(MarchingCubesGPU))]
public class SculptTexture3D : MonoBehaviour
{
    [Serializable]
    public class Brush {
        public string Name;
        public Vector3 position;
		public Vector3 lastPosition;
		public Vector3 normal;
		public float radius;
		public float strength;
		public bool additive;
    }

	public Transform palmLeftTransform;
	public Transform palmRightTransform;

	public ComputeShader sculptShader;

	CreateRenderTexture createTexture;

	public float strength;

	public Brush brushPalmLeft = new Brush() {
		Name = "Palm Left",
	};

	public Brush brushPalmRight = new Brush() {
		Name = "Palm Left",
	};

	int N = MarchingCubesGPU.N;

	// Start is called before the first frame update
	void Start()
    {
		createTexture = GetComponent<CreateRenderTexture>();

	}


	void UpdateBrushValues(in Brush brush, Transform transform) {
		brush.lastPosition = brush.position;
		brush.position = transform.position;
		brush.normal = (brush.position - brush.lastPosition).normalized;
		brush.strength = strength;
		brush.radius = transform.localScale.x * 0.5f;
	}

	void UpdateBrushes() {
		UpdateBrushValues(brushPalmLeft,palmLeftTransform);
		UpdateBrushValues(brushPalmRight,palmRightTransform);
	}


    // Update is called once per frame
    void Update()
    {
        if(createTexture == null || createTexture.m_clayBuffer == null) {
			return;
		}

		UpdateBrushes();
		sculptShader.SetInt("_Size",N);
		sculptShader.SetMatrix("_ClayModelMatrix", transform.localToWorldMatrix);
		sculptShader.SetVector("_BrushPalmLeftPosition",brushPalmLeft.position);
		sculptShader.SetVector("_BrushPalmLeftNormal",brushPalmLeft.normal);
		sculptShader.SetFloat("_BrushPalmLeftRadius",brushPalmLeft.radius);
		sculptShader.SetFloat("_BrushPalmLeftStrength",brushPalmLeft.strength);
		sculptShader.SetBool("_BrushPalmLeftAdditive",brushPalmLeft.additive);
		sculptShader.SetTexture(0,"_Result",createTexture.m_clayBuffer);
		sculptShader.Dispatch(0,N / 8, N / 8, N / 8);
	}
}
