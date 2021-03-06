//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "structs.mqh";

class CTdiStoch
{  
   private:
      datetime m_EntrySignalM5Time;
      datetime m_EntrySignalH1Time;
      datetime m_ExitSignalM5Time;
      datetime m_ExitSignalH1Time;
      
      datetime m_FillDataM5Time;
      datetime m_FillDataH1Time;
      
      double m_TslM5[20];
      double m_Stoch14M5[20];
      double m_Stoch100M5[20];
      double m_TslH1[20];
      double m_Stoch14H1[20];
      double m_Stoch100H1[20];
     
      void FillData(int tf, datetime currDt);
      
      
   public:
   
      CTdiStoch(){};
      Signal* EntrySignalM5(void);
      Signal* EntrySignalH1(void);
      
      Signal* ExitSignalM5(void);
      Signal* ExitSignalH1(void);
      
      int   EntrySignalM5_Buy(void);
      int   EntrySignalM5_Sell(void);
      int   EntrySignalH1_Buy(void);
      int   EntrySignalH1_Sell(void);
};

void CTdiStoch::FillData(int tf, datetime currDt)
{
   int i;
   
   if(tf == PERIOD_M5){
      if(m_FillDataM5Time == currDt){
      
      }else{
         m_FillDataM5Time = currDt;
         for(i=0;i<20;i++){
            m_TslM5[i]      = iCustom(NULL,PERIOD_M5,"TDI Red Green",5,i);  
            //Print("TDI M5 = ",m_TslM5[i]); 
            m_Stoch14M5[i]  = iStochastic(NULL, PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100M5[i] = iStochastic(NULL, PERIOD_M5, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   if(tf == PERIOD_H1){
      if(m_FillDataH1Time == currDt){
      
      }else{
         m_FillDataH1Time = currDt;
         for(i=0;i<20;i++){
            m_TslH1[i] = iCustom(NULL,PERIOD_H1,"TDI Red Green",5,i);
            m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   
}

Signal* CTdiStoch::EntrySignalM5(void)
{
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_EntrySignalM5Time == iTime(NULL,PERIOD_M5,0)){
      
   }else{
      m_EntrySignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_EntrySignalM5Time);
      int level = EntrySignalM5_Buy();
      if(level >-1){
         //sr = {OP_BUY,level,false,"CTdiStoch","CTdiStochM5"};
         sr.sign     = OP_BUY;
         sr.Level    = level;
         sr.unHedg   = false;
         sr.strategy = "CTdiStochM5";
         sr.comment  = "CTdiStochM5";
      }else{
         level = EntrySignalM5_Sell();
         if(level > -1){
            //sr = {OP_SELL,level,false,"CTdiStoch","CTdiStochM5"};
            sr.sign     = OP_SELL;
            sr.Level    = level;
            sr.unHedg   = false;
            sr.strategy = "CTdiStochM5";
            sr.comment  = "CTdiStochM5";
         }
      }
   }
   return sr;
}

Signal* CTdiStoch::EntrySignalH1(void)
{  
   Signal* sr = new Signal();
   //sr = {-1,-1,false,"",""};
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_EntrySignalH1Time == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_EntrySignalH1Time = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1, m_EntrySignalH1Time);
      int level = EntrySignalH1_Buy();
      if(level >-1){
         //sr = {OP_BUY,level,true,"CTdiStoch","CTdiStochH1"};
         sr.sign     = OP_BUY;
         sr.Level    = level;
         sr.unHedg   = true;
         sr.strategy = "CTdiStochH1";
         sr.comment  = "CTdiStochH1";
      }else{
         level = EntrySignalH1_Sell();
         if(level > -1){
            //sr = {OP_SELL,level,true,"CTdiStoch","CTdiStochH1"};
            sr.sign     = OP_SELL;
            sr.Level    = level;
            sr.unHedg   = true;
            sr.strategy = "CTdiStochH1";
            sr.comment  = "CTdiStochH1";
         }
      }
   }
   return sr;
}

Signal* CTdiStoch::ExitSignalM5(void){
   Signal* sr = new Signal();
   //sr = {-1,-1,false,"",""};
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_ExitSignalM5Time == iTime(NULL,PERIOD_M5,0)){
      
   }else{
      m_ExitSignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_ExitSignalM5Time);
      if(m_TslM5[1] > 32 && m_TslM5[2] < 32 && m_TslM5[3] < 32){
         //sr = {OP_SELL,1,false,"CTdiStoch","ExitSignalM5"}; 
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM5";
         sr.comment  = "ExitSignalM5";
      }
      
      if(m_TslM5[1] < 68 && m_TslM5[2] > 68 && m_TslM5[3] > 68){
         //sr = {OP_BUY,1,false,"CTdiStoch","ExitSignalM5"}; 
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM5";
         sr.comment  = "ExitSignalM5";
      }
   }
   return sr;
}

Signal* CTdiStoch::ExitSignalH1(void){
   
   Signal* sr = new Signal();
   //sr = {-1,-1,false,"",""};
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_ExitSignalH1Time == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_ExitSignalH1Time = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1, m_ExitSignalH1Time);
      if(m_TslH1[1] > 55 && m_TslH1[2] < 55 && m_TslH1[3] < 55){
         //sr = {OP_SELL,1,false,"CTdiStoch","ExitSignalH1"}; 
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalH1";
         sr.comment  = "ExitSignalH1";
      }
      
      if(m_TslH1[1] < 55 && m_TslH1[2] > 55 && m_TslH1[3] > 55){
         //sr = {OP_BUY,1,false,"CTdiStoch","ExitSignalH1"}; 
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalH1";
         sr.comment  = "ExitSignalH1";
      }
   }
   return sr;
}

////////////////////////////////////////////////////////////////
int CTdiStoch::EntrySignalM5_Buy(void){
   int level = -1;
  // Print("CTdiStoch::EntrySignalM5_Buy 1,2,3=",m_TslM5[1],m_TslM5[2],m_TslM5[3]);
   if(m_TslM5[1] > 32 && m_TslM5[2] < 32 && m_TslM5[3] < 32){
      level = 0;
      bool 
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
         
         if(m_Stoch14M5[i]<11){
            isStoch14Over = true;
         }
         if(m_Stoch100M5[i]<11){
            isStoch100Over = true;
         }
      }
      if((isStoch14Over || isStoch100Over) && m_Stoch100M5[1]>20){
         level = 1;
      }
   }
   return level;
}

int CTdiStoch::EntrySignalM5_Sell(void){
   int level = -1;
   //Print("CTdiStoch::EntrySignalM5_Sell 1,2,3=",m_TslM5[1],m_TslM5[2],m_TslM5[3]);
   if(m_TslM5[1] < 68 && m_TslM5[2] > 68 && m_TslM5[3] > 68){
      level = 0;
      bool 
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
         
         if(m_Stoch14M5[i]>89){
            isStoch14Over = true;
         }
         if(m_Stoch100M5[i]>89){
            isStoch100Over = true;
         }
      }
      if((isStoch14Over || isStoch100Over) && m_Stoch100M5[1]<80){
         level = 1;
      }
   }
   return level;
}

int CTdiStoch::EntrySignalH1_Buy(void){
   int level = -1;
   Print("CTdiStoch::EntrySignalH1_Buy ->",m_TslH1[1],", ",m_TslH1[2],", ",m_TslH1[3]);
   if(m_TslH1[1] > 32 && m_TslH1[2] < 32 && m_TslH1[3] < 32){
      level = 0;
      bool 
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
        
         if(m_Stoch14H1[i]<11){
            isStoch14Over = true;
         }
         if(m_Stoch100H1[i]<11){
            isStoch100Over = true;
         }
      }
      if((isStoch14Over || isStoch100Over) && m_Stoch100H1[1]>20){
         level = 1;
      }
   }
   return level;
}

int CTdiStoch::EntrySignalH1_Sell(void){
   int level = -1;
   Print("CTdiStoch::EntrySignalH1_Sell ->",m_TslH1[1],", ",m_TslH1[2],", ",m_TslH1[3]);
   if(m_TslH1[1] < 68 && m_TslH1[2] > 68 && m_TslH1[3] > 68){
      level = 0;
      bool 
           isStoch14Over = false, 
           isStoch100Over = false;
      for(int i=3;i<20;i++){
         
         if(m_Stoch14H1[i]>89){
            isStoch14Over = true;
         }
         if(m_Stoch14H1[i]>89){
            isStoch100Over = true;
         }
      }
      if((isStoch14Over || isStoch100Over) && m_Stoch100H1[1]<80){
         level = 1;
      }
   }
   return level;
}