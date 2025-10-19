using System.Collections;
using System.Collections.Generic;
using MarchingCubesGPUProject;
using UnityEngine;
using UnityEngine.Rendering;

public class CreateRenderTexture : MonoBehaviour
{
    public ComputeShader m_fillShader;
	public RenderTexture m_clayBuffer; // { get; private set; }

	// Start is called before the first frame update
	void Awake()
    {
        int N = MarchingCubesGPU.N;
		m_clayBuffer = new RenderTexture(N, N, 0, RenderTextureFormat.ARGBHalf,RenderTextureReadWrite.Default);
		m_clayBuffer.dimension = TextureDimension.Tex3D;
		m_clayBuffer.enableRandomWrite = true;		
		m_clayBuffer.useMipMap = false;
		m_clayBuffer.volumeDepth = N;
		m_clayBuffer.Create();


		m_fillShader.SetInt("_Size",N);
		m_fillShader.SetTexture(0,"_Result", m_clayBuffer);
		m_fillShader.Dispatch(0, N / 8, N / 8, N / 8);
	}

	void OnDestroy()
	{
		//MUST release buffers.
		m_clayBuffer.Release();
	}


}
