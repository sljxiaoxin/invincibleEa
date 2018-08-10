//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "inc\structs.mqh";
#include "inc\CTdiStoch.mqh";
#include "inc\COsMaDivStoch.mqh";

class CSignal
{  
   private:
      CTdiStoch* oTdiStoch;
      COsMaDivStoch* oOsMaDivStoch;
      
   public:
   
      CSignal(){
         oTdiStoch = new CTdiStoch();
         oOsMaDivStoch = new COsMaDivStoch();
      };
      Signal GetSignal(void);
};

Signal CSignal::GetSignal(){
   Signal sr;
   
}