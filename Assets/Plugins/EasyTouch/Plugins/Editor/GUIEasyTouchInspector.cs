using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(EasyTouch))]
public class GUIEasyTouchInspector : Editor {
	
	public override void OnInspectorGUI(){
			
		EasyTouch t = (EasyTouch)target;
		
		EditorGUILayout.Separator();
		HTEditorToolKit.DrawTitleChapter( "General properties");
		t.enable = EditorGUILayout.Toggle("Enable EasyTouch",t.enable);
		t.enableRemote = EditorGUILayout.Toggle("Enable unity remote",t.enableRemote);
		t.useBroadcastMessage = EditorGUILayout.Toggle("Broadcast messages",t.useBroadcastMessage);
		
		
		if (t.enable){
			
			// Auto select porperties
			HTEditorToolKit.DrawTitleChapter( "Auto-select properties");
			t.autoSelect = EditorGUILayout.Toggle("Enable auto-select",t.autoSelect);
			
			if (t.autoSelect){
				serializedObject.Update();
		   		EditorGUIUtility.LookLikeInspector();
		    	SerializedProperty layers = serializedObject.FindProperty("pickableLayers");
				EditorGUILayout.PropertyField( layers,true);
		   		serializedObject.ApplyModifiedProperties();
				EditorGUIUtility.LookLikeControls();
			}
			
			// General gesture properties
			HTEditorToolKit.DrawTitleChapter( "General gesture properties");
			t.StationnaryTolerance = EditorGUILayout.FloatField("Stationnary tolerance",t.StationnaryTolerance);
			t.longTapTime = EditorGUILayout.FloatField("Long tap time",t.longTapTime);
			t.swipeTolerance = EditorGUILayout.FloatField("Swipe tolerance",t.swipeTolerance);
			
			// Two fingers gesture
			HTEditorToolKit.DrawTitleChapter( "Two fingers gesture properties");
			t.enable2FingersGesture = EditorGUILayout.Toggle("2 fingers gesture",t.enable2FingersGesture);
	
			if (t.enable2FingersGesture){
				EditorGUILayout.Separator();
				t.enablePinch = EditorGUILayout.Toggle("Enable Pinch",t.enablePinch);
				if (t.enablePinch){
					t.minPinchLength = EditorGUILayout.FloatField("Min pinch length",t.minPinchLength);
				}
				EditorGUILayout.Separator();
				t.enableTwist = EditorGUILayout.Toggle("Enable twist",t.enableTwist);
				if (t.enableTwist){
					t.minTwistAngle = EditorGUILayout.FloatField("Min twist angle",t.minTwistAngle);
				}
				
			}
		}		
		 
		
		
	}
}
