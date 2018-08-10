//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "inc\structs.mqh";

class COsMaDivStoch
{  
   private:
      datetime m_CheckTimeM5;
      datetime m_CheckTimeH1;
      
      double m_Stoch14M5[20];
      double m_Stoch100M5[20];
      double m_Stoch14H1[20];
      double m_Stoch100H1[20];
      
      Signal m_CurrentH1Sr;
      
     
      void FillData(void);
      
      
   public:
   
      COsMaDivStoch(){
         m_CurrentH1Sr = {-1,-1,false,"",""};
      };
      Signal EntrySignalH1(void);
      int   EntrySignalH1_Buy(void);
      int   EntrySignalH1_Sell(void);
};

void COsMaDivStoch::FillData(int tf)
{
   for(int i=0;i<20;i++){
      if(tf == PERIOD_M5){
         m_Stoch14M5[i]  = iStochastic(NULL, PERIOD_M5, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         m_Stoch100M5[i] = iStochastic(NULL, PERIOD_M5, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      }
      if(tf == PERIOD_H1){
         m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
      }
   }
}


//signal by H1 but M5 for entry
Signal COsMaDivStoch::EntrySignalH1(void)
{ 
   if(m_CheckTimeH1 == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_CheckTimeH1 = iTime(NULL,PERIOD_H1,0);
      
      FillData(PERIOD_H1);
      m_CurrentH1Sr = {-1,-1,false,"",""};   //reset
      int level = EntrySignalH1_Buy();
      if(level >0){
         m_CurrentH1Sr = {OP_BUY,level,true,"COsMaDivStoch","COsMaDivStochH1"};
      }else{
         level = EntrySignalH1_Sell();
         if(level > 0){
            m_CurrentH1Sr = {OP_SELL,level,true,"COsMaDivStoch","COsMaDivStochH1"};
         }
      }
   }
   
   Signal sr = {-1,-1,false,"",""};
   if(m_CheckTimeM5 == iTime(NULL,PERIOD_M5,0)){
         
   }else{
      m_CheckTimeM5 = iTime(NULL,PERIOD_M5,0);
      
      FillData(PERIOD_M5);
      bool isStoch14M5Over = false,isStoch100M5Over = false;
      if(m_CurrentH1Sr.sign == OP_BUY){
         if(m_Stoch14M5[1] >20 && m_Stoch100M5>20 && m_Stoch14H1[1]>11 && m_Stoch100H1[1]>11){
            for(int i=3;i<10;i++){
               if(m_Stoch14M5[i]<11){
                  isStoch14M5Over = true;
               }
               if(m_Stoch100M5[i]<11){
                  isStoch100M5Over = true;
               }
            }
            if(isStoch14M5Over && isStoch100M5Over){
               sr = {OP_BUY,3,true,"COsMaDivStoch","COsMaDivStochH1"};
               m_CurrentH1Sr = {-1,-1,false,"",""};  //reset for next m5 not in
            }
         }
      }
      if(m_CurrentH1Sr.sign == OP_SELL){
         if(m_Stoch14M5[1] <80 && m_Stoch100M5<80 && m_Stoch14H1[1]<89 && m_Stoch100H1[1]<89){
            for(int i=3;i<10;i++){
               if(m_Stoch14M5[i]>89){
                  isStoch14M5Over = true;
               }
               if(m_Stoch100M5[i]>89){
                  isStoch100M5Over = true;
               }
            }
            if(isStoch14M5Over && isStoch100M5Over){
               sr = {OP_SELL,3,true,"COsMaDivStoch","COsMaDivStochH1"};
               m_CurrentH1Sr = {-1,-1,false,"",""};  //reset for next m5 not in
            }
         }
      }
   }
   return sr;
}

int COsMaDivStoch::EntrySignalH1_Buy(void){
   int level = -1;
   double bullishDivVal1 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",2,1);  //up
   double bullishDivVal2 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",2,2);  //up
   
   if(bullishDivVal1 != EMPTY_VALUE || bullishDivVal2 != EMPTY_VALUE){
      level = 2;
   }
   return level;
}

int COsMaDivStoch::EntrySignalH1_Sell(void){
   int level = -1;
   double bearishDivVal1 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",3,1);  //down
   double bearishDivVal2 = iCustom(NULL,PERIOD_M5,"FX5_Divergence_v2.0_yjx",3,2);  //down
   
   if(bearishDivVal1 != EMPTY_VALUE || bearishDivVal2 != EMPTY_VALUE){
      level = 2;
   }
   return level;
}