//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "inc\structs.mqh";

class CTdiStoch
{  
   private:
      datetime m_CheckTimeM5;
      datetime m_CheckTimeH1;
      double m_TslM5[20];
      double m_Stoch14M5[20];
      double m_Stoch100M5[20];
      double m_TslH1[20];
      double m_Stoch14H1[20];
      double m_Stoch100H1[20];
     
      void FillData(int tf);
      
      
   public:
   
      CTdiStoch(){};
      Signal EntrySignalM5(void);
      Signal EntrySignalH1(void);
      int   EntrySignalM5_Buy(void);
      int   EntrySignalM5_Sell(void);
      int   EntrySignalH1_Buy(void);
      int   EntrySignalH1_Sell(void);
};

void CTdiStoch::FillData(int tf)
{
   for(int i=0;i<20;i++){
      if(tf == PERIOD_M5){
         m_TslM5[i]      = iCustom(NULL,PERIOD_M5,"TDI Red Green",5,i);   
         m_Stoch14M5[i]  = iStochastic(NULL, PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         m_Stoch100M5[i] = iStochastic(NULL, PERIOD_M5, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      }
      if(tf == PERIOD_H1){
         m_TslH1[i] = iCustom(NULL,PERIOD_H1,"TDI Red Green",5,i);
         m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      }
   }
}

Signal CTdiStoch::EntrySignalM5(void)
{
   Signal sr;
   sr = {-1,-1,false,"",""};
   if(m_CheckTimeM5 == iTime(NULL,PERIOD_M5,0)){
      
   }else{
      m_CheckTimeM5 = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5);
      int level = EntrySignalM5_Buy();
      if(level >-1){
         sr = {OP_BUY,level,false,"CTdiStoch","CTdiStochM5"};
      }else{
         level = EntrySignalM5_Sell();
         if(level > -1){
            sr = {OP_SELL,level,false,"CTdiStoch","CTdiStochM5"};
         }
      }
   }
   return sr;
}

Signal CTdiStoch::EntrySignalH1(void)
{  
   Signal sr;
   sr = {-1,-1,false,"",""};
   if(m_CheckTimeH1 == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_CheckTimeH1 = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1);
      int level = EntrySignalH1_Buy();
      if(level >-1){
         sr = {OP_BUY,level,true,"CTdiStoch","CTdiStochH1"};
      }else{
         level = EntrySignalH1_Sell();
         if(level > -1){
            sr = {OP_SELL,level,true,"CTdiStoch","CTdiStochH1"};
         }
      }
   }
   return sr;
}

int CTdiStoch::EntrySignalM5_Buy(void){
   int level = -1;
   if(m_TslM5[1] > 50 && m_TslM5[2] < 50){
      level = 0;
      bool isTdiOver = false,
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
         if(m_TslM5[i]<32){
            isTdiOver = true;
         }
         if(m_Stoch14M5[i]<11){
            isStoch14Over = true;
         }
         if(m_Stoch100M5[i]<11){
            isStoch100Over = true;
         }
      }
      if(isTdiOver && isStoch14Over && isStoch100Over){
         level = 3;
      }else if(isTdiOver && isStoch14Over){
         level = 2;
      }else if(isTdiOver && isStoch100Over){
         level = 2;
      }else if(isTdiOver){
         level = 1;
      }
   }
   return level;
}

int CTdiStoch::EntrySignalM5_Sell(void){
   int level = -1;
   if(m_TslM5[1] < 50 && m_TslM5[2] > 50){
      level = 0;
      bool isTdiOver = false,
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
         if(m_TslM5[i]>68){
            isTdiOver = true;
         }
         if(m_Stoch14M5[i]>89){
            isStoch14Over = true;
         }
         if(m_Stoch100M5[i]>89){
            isStoch100Over = true;
         }
      }
      if(isTdiOver && isStoch14Over && isStoch100Over){
         level = 3;
      }else if(isTdiOver && isStoch14Over){
         level = 2;
      }else if(isTdiOver && isStoch100Over){
         level = 2;
      }else if(isTdiOver){
         level = 1;
      }
   }
   return level;
}

int CTdiStoch::EntrySignalH1_Buy(void){
   int level = -1;
   if(m_TslH1[1] > 50 && m_TslH1[2] < 50){
      level = 0;
      bool isTdiOver = false,
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
         if(m_TslH1[i]<32){
            isTdiOver = true;
         }
         if(m_Stoch14H1[i]<11){
            isStoch14Over = true;
         }
         if(m_Stoch100H1[i]<11){
            isStoch100Over = true;
         }
      }
      if(isTdiOver && isStoch14Over && isStoch100Over){
         level = 3;
      }else if(isTdiOver && isStoch14Over){
         level = 2;
      }else if(isTdiOver && isStoch100Over){
         level = 2;
      }else if(isTdiOver){
         level = 1;
      }
   }
   return level;
}

int CTdiStoch::EntrySignalH1_Sell(void){
   int level = -1;
   if(m_TslH1[1] < 50 && m_TslH1[2] > 50){
      level = 0;
      bool isTdiOver = false,
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
         if(m_TslH1[i]>68){
            isTdiOver = true;
         }
         if(m_Stoch14H1[i]>89){
            isStoch14Over = true;
         }
         if(m_Stoch14H1[i]>89){
            isStoch100Over = true;
         }
      }
      if(isTdiOver && isStoch14Over && isStoch100Over){
         level = 3;
      }else if(isTdiOver && isStoch14Over){
         level = 2;
      }else if(isTdiOver && isStoch100Over){
         level = 2;
      }else if(isTdiOver){
         level = 1;
      }
   }
   return level;
}