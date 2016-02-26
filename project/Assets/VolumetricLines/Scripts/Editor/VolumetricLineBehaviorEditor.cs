using System;
using UnityEditor;
using UnityEngine;
using System.Collections;
using VolumetricLines;
using VolumetricLines.Utils;

[CustomEditor(typeof(VolumetricLineBehavior))] 
public class VolumetricLineBehaviorEditor : Editor
{
	VolumetricLineBehavior m_Instance;
	PropertyField[] m_fields;
	
	public void OnEnable()
	{
		m_Instance = target as VolumetricLineBehavior;
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
