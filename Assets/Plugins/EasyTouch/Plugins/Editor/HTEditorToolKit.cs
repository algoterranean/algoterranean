// HTEditorTool v1.0 (September 2012)
// HTEditorTool library is copyright (c) of Hedgehog Team
// Please send feedback or bug reports to the.hedgehog.team@gmail.com
using UnityEngine;
using System.Collections;
using UnityEditor;

public class HTEditorToolKit{
	
	private static Texture2D whiteTexture;
	
	public static Rect DrawTitleChapter(string text)
	{
	    GUILayout.Space(30);
	    Rect lastRect = GUILayoutUtility.GetLastRect();
	    lastRect.yMin = lastRect.yMin + 5;
	    lastRect.yMax = lastRect.yMax- 5;
	    lastRect.width =  Screen.width;
		 
      
		GUIStyle titleStyle = EditorStyles.boldLabel;
		titleStyle.normal.textColor = Color.blue;
        GUI.Label(new Rect(lastRect.x + 3, lastRect.y, lastRect.width - 5, lastRect.height), text, titleStyle);
		
		GUI.color = Color.white;
	    GUI.DrawTexture(new Rect(0, lastRect.yMax-4, Screen.width, 1f), GetWhiteTexture());
		GUI.color = Color.gray;
	    GUI.DrawTexture(new Rect(0, lastRect.yMax-3, Screen.width, 1f), GetWhiteTexture());
		GUI.color = Color.white;;
		
		return lastRect;
	}
		
	public static void DrawSeparatorLine()
	{
		
	    GUILayout.Space(10);
        Rect lastRect = GUILayoutUtility.GetLastRect();
		
		GUI.color = Color.white;
	    GUI.DrawTexture(new Rect(0, lastRect.yMax-1, Screen.width, 1f), GetWhiteTexture());
		GUI.color = Color.gray;
	    GUI.DrawTexture(new Rect(0, lastRect.yMax-0, Screen.width, 1f), GetWhiteTexture());
		GUI.color = Color.white;
	}
	
	#region Asset tool
	public static bool CreateAssetDirectory(string rootPath,string name){
		string directory = rootPath + "/" +  name;
		if (!System.IO.Directory.Exists(directory)){
			AssetDatabase.CreateFolder(rootPath,name);
			return true;
		}
		return false;
	}

	public static string GetAssetRootPath( string path){
		
		string[] tokens = path.Split('/');
		
		path="";
		for (int i=0;i<tokens.Length-1;i++){
			path+= tokens[i] +"/";
		}
		return path;
	}
	#endregion
	
	private static Texture2D GetWhiteTexture(){
		
		if (whiteTexture==null){
			whiteTexture = CreateWhiteTexture();
		}
		return whiteTexture;
	}
	
	private static Texture2D CreateWhiteTexture(){
	
		Texture2D myTexture = new Texture2D(1, 1);
		
	    myTexture.set_name("White texture by Hedgehog Team");
	    myTexture.hideFlags = HideFlags.HideInInspector;
	    myTexture.filterMode = FilterMode.Bilinear;
	    myTexture.SetPixel(0, 0, Color.white);
		myTexture.hideFlags = HideFlags.DontSave;
	    myTexture.Apply();
	    
		return myTexture;
		
	}



}
