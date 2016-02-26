using System;
using UnityEditor;
using UnityEngine;
using System.Collections;
using VolumetricLines;
using VolumetricLines.Utils;

[CustomEditor(typeof(VolumetricLineStripBehavior))] 
public class VolumetricLineStripBehaviorEditor : Editor
{
	VolumetricLineStripBehavior m_Instance;
	PropertyField[] m_fields;
	
	public void OnEnable()
	{
		m_Instance = target as VolumetricLineStripBehavior;
		m_fields = ExposeProperties.GetProperties(m_Instance);
	}
	
	public override void OnInspectorGUI()
	{
		if (m_Instance == null)
			return;
		this.DrawDefaultInspector();
		ExposeProperties.Expose(m_fields);
	}
}
