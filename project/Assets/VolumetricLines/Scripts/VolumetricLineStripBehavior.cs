using UnityEngine;
using System.Collections;
using VolumetricLines.Utils;

namespace VolumetricLines
{
	/// <summary>
	/// Render a line strip of volumetric lines
	/// 
	/// Based on the Volumetric lines algorithm by SÃ©bastien Hillaire
	/// http://sebastien.hillaire.free.fr/index.php?option=com_content&view=article&id=57&Itemid=74
	/// 
	/// Thread in the Unity3D Forum:
	/// http://forum.unity3d.com/threads/181618-Volumetric-lines
	/// 
	/// Unity3D port by Johannes Unterguggenberger
	/// johannes.unterguggenberger@gmail.com
	/// 
	/// Thanks to Michael Probst for support during development.
	/// 
	/// Thanks for bugfixes and improvements to Unity Forum User "Mistale"
	/// http://forum.unity3d.com/members/102350-Mistale
	/// </summary>
	[RequireComponent(typeof(MeshFilter))]
	[RequireComponent(typeof(Renderer))]
	public class VolumetricLineStripBehavior : MonoBehaviour 
	{
		private bool m_updateLineColor;
		private bool m_updateLineWidth;

		#region member variables
		/// <summary>
		/// Set to true to change the material's color to the color specified with "Line Color"
		/// </summary>
		[SerializeField] 
		[HideInInspector]
		private bool m_setLineColorAtStart;
		
		/// <summary>
		/// The material is set to this color in Start() if "Set Material Color" is set to true
		/// </summary>
		[SerializeField] 
		[HideInInspector]
		private Color m_lineColor;

		/// <summary>
		/// The width of the line
		/// </summary>
		[SerializeField] 
		[HideInInspector]
		private float m_lineWidth;

		/// <summary>
		/// The vertices of the line
		/// </summary>
		[SerializeField]
		private Vector3[] m_lineVertices;
		#endregion

		#region properties shown in inspector via ExposeProperty
		/// <summary>
		/// Set to true to change the line material's color to the color specified via 'LineColor' property.
		/// Set to false to leave the color like in the original material.
		/// Does not have any effect after Start() has been called.
		/// </summary>
		[ExposeProperty]
		public bool SetLineColorAtStart 
		{
			get { return m_setLineColorAtStart; }
			set { m_setLineColorAtStart = value; }
		}
		
		/// <summary>
		/// Gets or sets the color of the line. This can be used during runtime
		/// regardless of SetLinePropertiesAtStart-property's value.
		/// </summary>
		[ExposeProperty]
		public Color LineColor 
		{
			get { return m_lineColor; }
			set { m_lineColor = value; m_updateLineColor = true; }
		}
		
		/// <summary>
		/// Gets or sets the width of the line. This can be used during runtime
		/// regardless of SetLineColorAtStart-propertie's value.
		/// </summary>
		[ExposeProperty]
		public float LineWidth 
		{
			get { return m_lineWidth; }
			set { m_lineWidth = value; m_updateLineWidth = true; }
		}
		#endregion

		/// <summary>
		/// Gets the vertices of this line strip
		/// </summary>
		public Vector3[] LineVertices
		{
			get { return m_lineVertices; }
		}

		#region Unity callbacks and public methods
		void Start () 
		{
			UpdateLineVertices(m_lineVertices);
			// Need to duplicate the material, otherwise multiple volume lines would interfere
			GetComponent<Renderer>().material = GetComponent<Renderer>().material;
			if (m_setLineColorAtStart)
			{
				GetComponent<Renderer>().sharedMaterial.color = m_lineColor;
				GetComponent<Renderer>().sharedMaterial.SetFloat("_LineWidth", m_lineWidth);
			}
			else 
			{
				m_lineColor = GetComponent<Renderer>().sharedMaterial.color;
				m_lineWidth = GetComponent<Renderer>().sharedMaterial.GetFloat("_LineWidth");
			}
			GetComponent<Renderer>().sharedMaterial.SetFloat("_LineScale", transform.GetGlobalUniformScaleForLineWidth());
			m_updateLineColor = false;
			m_updateLineWidth = false;
		}

		/// <summary>
		/// Updates the vertices of this VolumetricLineStrip.
		/// This is an expensive operation.
		/// </summary>
		/// <param name="m_newSetOfVertices">M_new set of vertices.</param>
		public void UpdateLineVertices(Vector3[] m_newSetOfVertices)
		{
			if (m_newSetOfVertices.Length < 3)
			{
				Debug.LogError("Add at least 3 vertices to the VolumetricLineStrip");
				return;
			}

			m_lineVertices = m_newSetOfVertices;
			
			// fill vertex positions, and indices
			// 2 for each position, + 2 for the start, + 2 for the end
			Vector3[] vertexPositions = new Vector3[m_lineVertices.Length * 2 + 4];
			// there are #vertices - 2 faces, and 3 indices each
			int[] indices = new int[(m_lineVertices.Length * 2 + 2) * 3];
			int v = 0;
			int x = 0;
			vertexPositions[v++] = m_lineVertices[0];
			vertexPositions[v++] = m_lineVertices[0];
			for (int i=0; i < m_lineVertices.Length; ++i)
			{
				vertexPositions[v++] = m_lineVertices[i];
				vertexPositions[v++] = m_lineVertices[i];
				indices[x++] = v - 2;
				indices[x++] = v - 3;
				indices[x++] = v - 4;
				indices[x++] = v - 1;
				indices[x++] = v - 2;
				indices[x++] = v - 3;
			}
			vertexPositions[v++] = m_lineVertices[m_lineVertices.Length - 1];
			vertexPositions[v++] = m_lineVertices[m_lineVertices.Length - 1];
			indices[x++] = v - 2;
			indices[x++] = v - 3;
			indices[x++] = v - 4;
			indices[x++] = v - 1;
			indices[x++] = v - 2;
			indices[x++] = v - 3;
			
			// fill texture coordinates and vertex offsets
			Vector2[] texCoords		  = new Vector2[vertexPositions.Length];
			Vector2[] vertexOffsets	  = new Vector2[vertexPositions.Length];
			int t = 0;
			int o = 0;
			texCoords[t++] = new Vector2(1.0f, 0.0f);
			texCoords[t++] = new Vector2(1.0f, 1.0f);
			texCoords[t++] = new Vector2(0.5f, 0.0f);
			texCoords[t++] = new Vector2(0.5f, 1.0f);
			vertexOffsets[o++] = new Vector2(1.0f,	-1.0f);
			vertexOffsets[o++] = new Vector2(1.0f,	 1.0f);
			vertexOffsets[o++] = new Vector2(0.0f,	-1.0f);
			vertexOffsets[o++] = new Vector2(0.0f,	 1.0f);
			for (int i=1; i < m_lineVertices.Length - 1; ++i)
			{
				if ((i & 0x1) == 0x1)
				{
					texCoords[t++] = new Vector2(0.5f, 0.0f);
					texCoords[t++] = new Vector2(0.5f, 1.0f);
				}
				else 
				{
					texCoords[t++] = new Vector2(0.5f, 0.0f);
					texCoords[t++] = new Vector2(0.5f, 1.0f);
				}
				vertexOffsets[o++] = new Vector2(0.0f,	 1.0f);
				vertexOffsets[o++] = new Vector2(0.0f,	-1.0f);
			}
			texCoords[t++] = new Vector2(0.5f, 0.0f);
			texCoords[t++] = new Vector2(0.5f, 1.0f);
			texCoords[t++] = new Vector2(0.0f, 0.0f);
			texCoords[t++] = new Vector2(0.0f, 1.0f);
			vertexOffsets[o++] = new Vector2(0.0f,	 1.0f);
			vertexOffsets[o++] = new Vector2(0.0f,	-1.0f);
			vertexOffsets[o++] = new Vector2(1.0f,	 1.0f);
			vertexOffsets[o++] = new Vector2(1.0f,	-1.0f);
			
			
			// fill previous and next positions
			Vector3[] prevPositions = new Vector3[vertexPositions.Length];
			Vector4[] nextPositions = new Vector4[vertexPositions.Length];
			int p = 0;
			int n = 0;
			prevPositions[p++] = m_lineVertices[1];
			prevPositions[p++] = m_lineVertices[1];
			prevPositions[p++] = m_lineVertices[1];
			prevPositions[p++] = m_lineVertices[1];
			nextPositions[n++] = m_lineVertices[1];
			nextPositions[n++] = m_lineVertices[1];
			nextPositions[n++] = m_lineVertices[1];
			nextPositions[n++] = m_lineVertices[1];
			for (int i=1; i < m_lineVertices.Length - 1; ++i)
			{
				prevPositions[p++] = m_lineVertices[i-1];
				prevPositions[p++] = m_lineVertices[i-1];
				nextPositions[n++] = m_lineVertices[i+1];
				nextPositions[n++] = m_lineVertices[i+1];
			}
			prevPositions[p++] = m_lineVertices[m_lineVertices.Length - 2];
			prevPositions[p++] = m_lineVertices[m_lineVertices.Length - 2];
			prevPositions[p++] = m_lineVertices[m_lineVertices.Length - 2];
			prevPositions[p++] = m_lineVertices[m_lineVertices.Length - 2];
			nextPositions[n++] = m_lineVertices[m_lineVertices.Length - 2];
			nextPositions[n++] = m_lineVertices[m_lineVertices.Length - 2];
			nextPositions[n++] = m_lineVertices[m_lineVertices.Length - 2];
			nextPositions[n++] = m_lineVertices[m_lineVertices.Length - 2];
			
			// Need to set vertices before assigning new Mesh to the MeshFilter's mesh property
			Mesh mesh = new Mesh();
			mesh.vertices = vertexPositions;
			mesh.normals = prevPositions;
			mesh.tangents = nextPositions;
			mesh.uv = texCoords;
			mesh.uv2 = vertexOffsets;
			mesh.SetIndices(indices, MeshTopology.Triangles, 0);
			GetComponent<MeshFilter>().mesh = mesh;
		}

		void Update()
		{
			if (transform.hasChanged)
			{
				GetComponent<Renderer>().sharedMaterial.SetFloat("_LineScale", transform.GetGlobalUniformScaleForLineWidth());
			}
			if (m_updateLineColor)
			{
				GetComponent<Renderer>().sharedMaterial.color = m_lineColor;
				m_updateLineColor = false;
			}
			if (m_updateLineWidth)
			{
				GetComponent<Renderer>().sharedMaterial.SetFloat("_LineWidth", m_lineWidth);
				m_updateLineWidth = false;
			}
		}

		void OnDrawGizmos()
		{
			Gizmos.color = Color.green;
			for (int i=0; i < m_lineVertices.Length - 1; ++i)
			{
				Gizmos.DrawLine(gameObject.transform.TransformPoint(m_lineVertices[i]), gameObject.transform.TransformPoint(m_lineVertices[i+1]));
			}
		}
		#endregion
	}
}