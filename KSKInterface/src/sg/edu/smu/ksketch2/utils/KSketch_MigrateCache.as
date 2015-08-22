/**
 * Created by ramvibhakar on 02/08/15.
 */
package sg.edu.smu.ksketch2.utils {
import flash.net.SharedObject;
import com.adobe.serialization.json.JSON;
import sg.edu.smu.ksketch2.canvas.controls.KSketch_CacheControl;

public class KSketch_MigrateCache {
    private var _mySOV1:SharedObject = SharedObject.getLocal("mydata");
    private var _cacheControl:KSketch_CacheControl = new KSketch_CacheControl(null);
    public function KSketch_MigrateCache() {
    }
    public function migrateData(){
        if(_mySOV1.data != null){
            if(_mySOV1.data.userSketch) {
                var obj:Object = com.adobe.serialization.json.JSON.decode(_mySOV1.data.userSketch, true);
                buildCacheV2(obj.sketches)
            }
            if(_mySOV1.data.user){
                _cacheControl.user = com.adobe.serialization.json.JSON.decode(_mySOV1.data.user,true);
            }
            _mySOV1.clear();
        }
    }
    private function buildCacheV2(sketches:Array){
        if(sketches){
            for(var i:int=0; i<sketches.length;i++){
                _cacheControl.migrateCache(sketches[i]);
            }
        }

    }
}
}
