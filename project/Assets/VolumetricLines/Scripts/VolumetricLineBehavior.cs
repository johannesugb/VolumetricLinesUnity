using UnityEngine;
using System.Collections;
using VolumetricLines.Utils;

namespace VolumetricLines
{
	/// <summary>
	/// Render a single volumetric line
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
	public class VolumetricLineBehavior : MonoBehaviour 
	{
		private bool m_updateLineColor;
		private bool m_updateLineWidth;

		#region private variables
		/// <summary>
		/// The start position relative to the GameObject's origin
		/// </summary>
		[SerializeField] 
		[HideInInspector]
		private Vector3 m_startPos;
		
		/// <summary>
		/// The end position relative to the GameObject's origin
		/// </summary>
		[SerializeField] 
		[HideInInspector]
		private Vector3 m_endPos = new Vector3(0f, 0f, 100f);

		/// <summary>
		/// Set to true to change the material's color to the color specified with "Line Color".
		/// Set to false to leave the color like in the original material.
		/// </summary>
		[SerializeField] 
		[HideInInspector]
		private bool m_setLinePropertiesAtStart;

		/// <summary>
		/// Line Color
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
		

		private static readonly Vector2[] m_vline_texCoords = {
			new Vector2(1.0f, 1.0f),
			new Vector2(1.0f, 0.0f),
			new Vector2(0.5f, 1.0f),
			new Vector2(0.5f, 0.0f),
			new Vector2(0.5f, 0.0f),
			new Vector2(0.5f, 1.0f),
			new Vector2(0.0f, 0.0f),
			new Vector2(0.0f, 1.0f),
		};


		private static readonly Vector2[] m_vline_vertexOffsets = {
			 new Vector2(1.0f,	 1.0f),
			 new Vector2(1.0f,	-1.0f),
			 new Vector2(0.0f,	 1.0f),
			 new Vector2(0.0f,	-1.0f),
			 new Vector2(0.0f,	 1.0f),
			 new Vector2(0.0f,	-1.0f),
			 new Vector2(1.0f,	 1.0f),
			 new Vector2(1.0f,	-1.0f)
		};

		private static readonly int[] m_vline_indices =
		{
			2, 1, 0,
			3, 1, 2,
			4, 3, 2,
			5, 4, 2,
			4, 5, 6,
			6, 5, 7
		};
		#endregion

		#region properties shown in inspector via ExposeProperty
		/// <summary>
		/// Set or get the start position relative to the GameObject's origin
		/// </summary>
		[ExposeProperty]
		public Vector3 StartPos
		{
			get { return m_startPos; }
			set 
			{ 
				m_startPos = value; 
				SetStartAndEndPoints(m_startPos, m_endPos);
			}
		}

		/// <summary>
		/// Set or get the end position relative to the GameObject's origin
		/// </summary>
		[ExposeProperty]
		public Vector3 EndPos 
		{
			get { return m_endPos; }
			set 
			{
				m_endPos = value; 
				SetStartAndEndPoints(m_startPos, m_endPos);
			}
		}

		/// <summary>
		/// Set to true to change the line material's color to the color specified via 'LineColor' property.
		/// Set to false to leave the color like in the original material.
		/// Does not have any effect after Start() has been called.
		/// </summary>
		[ExposeProperty]
		public bool SetLinePropertiesAtStart 
		{
			get { return m_setLinePropertiesAtStart; }
			set { m_setLinePropertiesAtStart = value; }
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

		#region methods
		/// <summary>
		/// Sets the start and end points - updates the data of the Mesh.
		/// </summary>
		public void SetStartAndEndPoints(Vector3 startPoint, Vector3 endPoint)
		{
			Vector3[] vertexPositions = {
				startPoint,
				startPoint,
				startPoint,
				startPoint,
				endPoint,
				endPoint,
				endPoint,
				endPoint,
			};
			
			Vector3[] other = {
				endPoint,
				endPoint,
				endPoint,
				endPoint,
				startPoint,
				startPoint,
				startPoint,
				startPoint,
			};
			
			var mesh = GetComponent<MeshFilter>().sharedMesh;
			if (null != mesh)
			{
				mesh.vertices = vertexPositions;
				mesh.normals = other;
			}
		}
		
		// Vertex data is updated only in Start() unless m_dynamic is set to true
		void Start () 
		{
			Vector3[] vertexPositions = {
				m_startPos,
				m_startPos,
				m_startPos,
				m_startPos,
				m_endPos,
				m_endPos,
				m_endPos,
				m_endPos,
			};
			
			Vector3[] other = {
				m_endPos,
				m_endPos,
				m_endPos,
				m_endPos,
				m_startPos,
				m_startPos,
				m_startPos,
				m_startPos,
			};
			
			// Need to set vertices before assigning new Mesh to the MeshFilter's mesh property
			Mesh mesh = new Mesh();
			mesh.vertices = vertexPositions;
			mesh.normals = other;
			mesh.uv = m_vline_texCoords;
			mesh.uv2 = m_vline_vertexOffsets;
			mesh.SetIndices(m_vline_indices, MeshTopology.Triangles, 0);
			GetComponent<MeshFilter>().mesh = mesh;
			// Need to duplicate the material, otherwise multiple volume lines would interfere
			GetComponent<Renderer>().material = GetComponent<Renderer>().material;
			if (SetLinePropertiesAtStart)
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
			Gizmos.DrawLine(gameObject.transform.TransformPoint(m_startPos), gameObject.transform.TransformPoint(m_endPos));
		}
		#endregion
	}
}