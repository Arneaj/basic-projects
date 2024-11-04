#include<iostream>
#include"../backend/imgui.h"
#include"../headers/Application.h"
//using namespace std;

namespace App
{
    void render_UI()
    {
        ImGui::Begin("Settings");
        ImGui::Button("Hello");

        float value = 0;
        ImGui::DragFloat("Value", &value);
        
        ImGui::End();
    }
}

