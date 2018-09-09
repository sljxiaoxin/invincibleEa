//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

class Signal {
    public:
    
    int sign;  //-1:none ,0:buy ,1:sell
    int Level; //-1:none, 0:low, 1:mid , 2:high ,3:strong high
    bool unHedg; //auto close hedg
    string strategy;
    string comment;
    int intTP;
    int intSL;
    int intHD; //hedge
    
    Signal(){
      intTP = 0;
      intSL = 0;
      intHD = 0;
    };
};

class Setting {
   public:
   int       MagicNumber;
   double    Lots;
   int       intTP;
   int       intSL;
   double    distance;
   bool      isUse_MaEntryM15;
   bool      isUse_MaEntryH1;
   bool      isUse_StochEntryM5;
   bool      isUse_StochEntryH1;
   bool      isUse_TdiStochEntryM5;
   bool      isUse_TdiStochEntryH1;
   bool      isUse_OsMaDivStochEntryH1;
   int       intMaxItems;
   int       intMaxActiveItems;
   int       gridSize;
   int       maxMarti;
   double    mutilplier;
   Setting(){};
};