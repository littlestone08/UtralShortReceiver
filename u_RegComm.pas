unit u_RegComm;

interface
const
  DDSSDIO0  = 0;
  DDSSDIO1  = 1;
  DDSSCLK   = 2;
  DDSIO     = 4;
  DDSRESET  = 8;
  DRGCtl0   = 0;
  DRGCtl1   = 16;
var

PrefilePin: Integer;

//控制功能寄存器1 地址：0x00

CFR1_1: Byte;
CFR1_2: Byte;
CFR1_3: Byte;
CFR1_4: Byte;

//控制功能寄存器2 地址：0x01

CFR2_1: Byte;
CFR2_2: Byte;
CFR2_3: Byte;
CFR2_4: Byte;

//控制功能寄存器3 地址：0x02

CFR3_1: Byte;
CFR3_2: Byte;
CFR3_3: Byte;
CFR3_4: Byte;

//辅助DAC控制寄存器 地址：0x03

DAC_1: Byte;
DAC_2: Byte;
DAC_3: Byte;
DAC_4: Byte;

//（自动I/O Update）I/O Update 速率寄存器 地址：0x04

IO_1: Byte;
IO_2: Byte;
IO_3: Byte;
IO_4: Byte;

//频率控制字 地址：0x07

FTW_1: Byte;
FTW_2: Byte;
FTW_3: Byte;
FTW_4: Byte;

//相位偏移寄存器 地址：0x08

POW_1: Byte;
POW_2: Byte;

// 地址：0x09

ASF_1: Byte;
ASF_2: Byte;
ASF_3: Byte;
ASF_4: Byte;

//多器件同步寄存器 地址：0x0A

MS_1: Byte;
MS_2: Byte;
MS_3: Byte;
MS_4: Byte;

//扫频频率上下限寄存器 地址：0x0B
//频率上限
DRU_1: Byte;
DRU_2: Byte;
DRU_3: Byte;
DRU_4: Byte;
//频率下限
DRL_1: Byte;
DRL_2: Byte;
DRL_3: Byte;
DRL_4: Byte;


//扫频频率步进寄存器 地址：0x0C
//频率增大时步进
DRD_1: Byte;
DRD_2: Byte;
DRD_3: Byte;
DRD_4: Byte;
//频率减小时步进
DRI_1: Byte;
DRI_2: Byte;
DRI_3: Byte;
DRI_4: Byte;

//扫频频率切换间隔寄存器 地址：0x0D

DRRN_1: Byte;
DRRN_2: Byte;
DRRP_1: Byte;
DRRP_2: Byte;

//单音Prefile0寄存器 地址：0x0E
//幅度
PASF1_1: Byte;
PASF1_2: Byte;
//相位
PPOW1_1: Byte;
PPOW1_2: Byte;
//频率
PFTW1_1: Byte;
PFTW1_2: Byte;
PFTW1_3: Byte;
PFTW1_4: Byte;

//RAM Prefile0寄存器 地址：0x0E
//幅度
RASF1_1: Byte;
RASF1_2: Byte;
//相位
RPOW1_1: Byte;
RPOW1_2: Byte;
//频率
RFTW1_1: Byte;
RFTW1_2: Byte;
RFTW1_3: Byte;
RFTW1_4: Byte;

//单音Prefile1寄存器 地址：0x0F
//幅度
PASF2_1: Byte;
PASF2_2: Byte;
//相位
PPOW2_1: Byte;
PPOW2_2: Byte;
//频率
PFTW2_1: Byte;
PFTW2_2: Byte;
PFTW2_3: Byte;
PFTW2_4: Byte;

//RAM Prefile1寄存器 地址：0x0F
//幅度
RASF2_1: Byte;
RASF2_2: Byte;
//相位
RPOW2_1: Byte;
RPOW2_2: Byte;
//频率
RFTW2_1: Byte;
RFTW2_2: Byte;
RFTW2_3: Byte;
RFTW2_4: Byte;

//单音Prefile2寄存器 地址：0x10
//幅度
PASF3_1: Byte;
PASF3_2: Byte;
//相位
PPOW3_1: Byte;
PPOW3_2: Byte;
//频率
PFTW3_1: Byte;
PFTW3_2: Byte;
PFTW3_3: Byte;
PFTW3_4: Byte;

//RAM Prefile2寄存器 地址：0x10
//幅度
RASF3_1: Byte;
RASF3_2: Byte;
//相位
RPOW3_1: Byte;
RPOW3_2: Byte;
//频率
RFTW3_1: Byte;
RFTW3_2: Byte;
RFTW3_3: Byte;
RFTW3_4: Byte;

//单音Prefile3寄存器 地址：0x11
//幅度
PASF4_1: Byte;
PASF4_2: Byte;
//相位
PPOW4_1: Byte;
PPOW4_2: Byte;
//频率
PFTW4_1: Byte;
PFTW4_2: Byte;
PFTW4_3: Byte;
PFTW4_4: Byte;

//RAM Prefile3寄存器 地址：0x11
//幅度
RASF4_1: Byte;
RASF4_2: Byte;
//相位
RPOW4_1: Byte;
RPOW4_2: Byte;
//频率
RFTW4_1: Byte;
RFTW4_2: Byte;
RFTW4_3: Byte;
RFTW4_4: Byte;

//单音Prefile4寄存器 地址：0x12
//幅度
PASF5_1: Byte;
PASF5_2: Byte;
//相位
PPOW5_1: Byte;
PPOW5_2: Byte;
//频率
PFTW5_1: Byte;
PFTW5_2: Byte;
PFTW5_3: Byte;
PFTW5_4: Byte;

//RAM Prefile4寄存器 地址：0x12
//幅度
RASF5_1: Byte;
RASF5_2: Byte;
//相位
RPOW5_1: Byte;
RPOW5_2: Byte;
//频率
RFTW5_1: Byte;
RFTW5_2: Byte;
RFTW5_3: Byte;
RFTW5_4: Byte;

//单音Prefile5寄存器 地址：0x13
//幅度
PASF6_1: Byte;
PASF6_2: Byte;
//相位
PPOW6_1: Byte;
PPOW6_2: Byte;
//频率
PFTW6_1: Byte;
PFTW6_2: Byte;
PFTW6_3: Byte;
PFTW6_4: Byte;

//RAM Prefile5寄存器 地址：0x13
//幅度
RASF6_1: Byte;
RASF6_2: Byte;
//相位
RPOW6_1: Byte;
RPOW6_2: Byte;
//频率
RFTW6_1: Byte;
RFTW6_2: Byte;
RFTW6_3: Byte;
RFTW6_4: Byte;

//单音Prefile6寄存器 地址：0x14
//幅度
PASF7_1: Byte;
PASF7_2: Byte;
//相位
PPOW7_1: Byte;
PPOW7_2: Byte;
//频率
PFTW7_1: Byte;
PFTW7_2: Byte;
PFTW7_3: Byte;
PFTW7_4: Byte;

//RAM Prefile6寄存器 地址：0x14
//幅度
RASF7_1: Byte;
RASF7_2: Byte;
//相位
RPOW7_1: Byte;
RPOW7_2: Byte;
//频率
RFTW7_1: Byte;
RFTW7_2: Byte;
RFTW7_3: Byte;
RFTW7_4: Byte;

//单音Prefile7寄存器 地址：0x15
//幅度
PASF8_1: Byte;
PASF8_2: Byte;
//相位
PPOW8_1: Byte;
PPOW8_2: Byte;
//频率
PFTW8_1: Byte;
PFTW8_2: Byte;
PFTW8_3: Byte;
PFTW8_4: Byte;

//RAM Prefile7寄存器 地址：0x15
//幅度
RASF8_1: Byte;
RASF8_2: Byte;
//相位
RPOW8_1: Byte;
RPOW8_2: Byte;
//频率
RFTW8_1: Byte;
RFTW8_2: Byte;
RFTW8_3: Byte;
RFTW8_4: Byte;

//RAM寄存器 地址：0x16

RAM_1: Byte;
RAM_2: Byte;
RAM_3: Byte;
RAM_4: Byte;
RAM_5: Byte;
RAM_6: Byte;
RAM_7: Byte;
RAM_8: Byte;


implementation

end.
