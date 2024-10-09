
using UnityEngine;

namespace NekoLegends
{
    public class InteractWithWaterfall : MonoBehaviour
    {
        public bool isEnabled = true;

        public bool resetWaterFall;

        //so editor won't show hole after play is turned off
        void OnDisable()
        {
            Shader.SetGlobalVector("_NekoLegendsWaterfallObjectInteraction", new Vector4(0, 0, 0, 0));
        }


        void Update()
        {
            if (isEnabled)
            {
                Shader.SetGlobalVector("_NekoLegendsWaterfallObjectInteraction", new Vector4(this.transform.position.x, this.transform.position.y, this.transform.position.z, this.transform.localScale.x));
            }

            if (resetWaterFall)
            {
                Shader.SetGlobalVector("_NekoLegendsWaterfallObjectInteraction", new Vector4(0, 0, 0, 0));
                isEnabled = false;
                resetWaterFall = false;
            }

        }
    }
}