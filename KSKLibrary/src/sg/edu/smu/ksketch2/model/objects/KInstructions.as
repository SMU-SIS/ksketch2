/**
 * Created by ramvs on 6/5/2015.
 */
package sg.edu.smu.ksketch2.model.objects {

public class KInstructions {
    private var instructions:Array;
    private var objectIDs:Array;
    public function KInstructions(xml:XML) {
        instructions = new Array();
        objectIDs = new Array();

        var introduction:Array = new Array();
        var introductionIDs:Array = new Array();
        var introductionList:XMLList = xml.introduction.instructions;
        var i:int;
        for(i=0; i < introductionList.length();i++) {
            introduction.push(introductionList[i].*.toString());
            introductionIDs.push(introductionList[i].@id)
        }
        instructions.push(introduction);
        objectIDs.push(introductionIDs);

        var recall:Array = new Array();
        var recallIDs:Array = new Array();
        var recallList:XMLList = xml.recall.instructions;
        var i:int;
        for(i=0; i < recallList.length();i++) {
            recall.push(recallList[i].*.toString());
            recallIDs.push(recallList[i].@id)
        }
        instructions.push(recall);
        objectIDs.push(recallIDs);

        var trace:Array = new Array();
        var traceIDs:Array = new Array();
        var traceList:XMLList = xml.trace.instructions;
        for(i=0; i < traceList.length();i++) {
            trace.push(traceList[i].*.toString());
            traceIDs.push(traceList[i].@id)
        }
        instructions.push(trace);
        objectIDs.push(traceIDs);


        var track:Array = new Array();
        var trackIDs:Array = new Array();
        var trackList:XMLList = xml.track.instructions;
        for(i=0; i < trackList.length();i++) {
            track.push(trackList[i].*.toString());
            trackIDs.push(trackList[i].@id)
        }
        instructions.push(track);
        objectIDs.push(trackIDs);

        var recreate:Array = new Array();
        var recreateIDs:Array = new Array();
        var recreateList:XMLList = xml.recreate.instructions;
        for(i=0; i < recreateList.length();i++) {
            recreate.push(recreateList[i].*.toString());
            recreateIDs.push(recreateList[i].@id)
        }
        instructions.push(recreate);
        objectIDs.push(recreateIDs);

    }
    public function getInstructions():Array
    {
        return instructions;
    }

    public function getObjectIDs():Array
    {
        return objectIDs;
    }
}

}
