//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015."
#property link      "http://www.mql5.com"

struct Signal {
    int sign;  //-1:none ,0:buy ,1:sell
    int Level; //-1:none, 0:low, 1:mid , 2:high ,3:strong high
    bool isReleaseHedg;
    string strategy;
    string comment;
};