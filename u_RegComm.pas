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

//���ƹ��ܼĴ���1 ��ַ��0x00

CFR1_1: Byte;
CFR1_2: Byte;
CFR1_3: Byte;
CFR1_4: Byte;

//���ƹ��ܼĴ���2 ��ַ��0x01

CFR2_1: Byte;
CFR2_2: Byte;
CFR2_3: Byte;
CFR2_4: Byte;

//���ƹ��ܼĴ���3 ��ַ��0x02

CFR3_1: Byte;
CFR3_2: Byte;
CFR3_3: Byte;
CFR3_4: Byte;

//����DAC���ƼĴ��� ��ַ��0x03

DAC_1: Byte;
DAC_2: Byte;
DAC_3: Byte;
DAC_4: Byte;

//���Զ�I/O Update��I/O Update ���ʼĴ��� ��ַ��0x04

IO_1: Byte;
IO_2: Byte;
IO_3: Byte;
IO_4: Byte;

//Ƶ�ʿ����� ��ַ��0x07

FTW_1: Byte;
FTW_2: Byte;
FTW_3: Byte;
FTW_4: Byte;

//��λƫ�ƼĴ��� ��ַ��0x08

POW_1: Byte;
POW_2: Byte;

// ��ַ��0x09

ASF_1: Byte;
ASF_2: Byte;
ASF_3: Byte;
ASF_4: Byte;

//������ͬ���Ĵ��� ��ַ��0x0A

MS_1: Byte;
MS_2: Byte;
MS_3: Byte;
MS_4: Byte;

//ɨƵƵ�������޼Ĵ��� ��ַ��0x0B
//Ƶ������
DRU_1: Byte;
DRU_2: Byte;
DRU_3: Byte;
DRU_4: Byte;
//Ƶ������
DRL_1: Byte;
DRL_2: Byte;
DRL_3: Byte;
DRL_4: Byte;


//ɨƵƵ�ʲ����Ĵ��� ��ַ��0x0C
//Ƶ������ʱ����
DRD_1: Byte;
DRD_2: Byte;
DRD_3: Byte;
DRD_4: Byte;
//Ƶ�ʼ�Сʱ����
DRI_1: Byte;
DRI_2: Byte;
DRI_3: Byte;
DRI_4: Byte;

//ɨƵƵ���л�����Ĵ��� ��ַ��0x0D

DRRN_1: Byte;
DRRN_2: Byte;
DRRP_1: Byte;
DRRP_2: Byte;

//����Prefile0�Ĵ��� ��ַ��0x0E
//����
PASF1_1: Byte;
PASF1_2: Byte;
//��λ
PPOW1_1: Byte;
PPOW1_2: Byte;
//Ƶ��
PFTW1_1: Byte;
PFTW1_2: Byte;
PFTW1_3: Byte;
PFTW1_4: Byte;

//RAM Prefile0�Ĵ��� ��ַ��0x0E
//����
RASF1_1: Byte;
RASF1_2: Byte;
//��λ
RPOW1_1: Byte;
RPOW1_2: Byte;
//Ƶ��
RFTW1_1: Byte;
RFTW1_2: Byte;
RFTW1_3: Byte;
RFTW1_4: Byte;

//����Prefile1�Ĵ��� ��ַ��0x0F
//����
PASF2_1: Byte;
PASF2_2: Byte;
//��λ
PPOW2_1: Byte;
PPOW2_2: Byte;
//Ƶ��
PFTW2_1: Byte;
PFTW2_2: Byte;
PFTW2_3: Byte;
PFTW2_4: Byte;

//RAM Prefile1�Ĵ��� ��ַ��0x0F
//����
RASF2_1: Byte;
RASF2_2: Byte;
//��λ
RPOW2_1: Byte;
RPOW2_2: Byte;
//Ƶ��
RFTW2_1: Byte;
RFTW2_2: Byte;
RFTW2_3: Byte;
RFTW2_4: Byte;

//����Prefile2�Ĵ��� ��ַ��0x10
//����
PASF3_1: Byte;
PASF3_2: Byte;
//��λ
PPOW3_1: Byte;
PPOW3_2: Byte;
//Ƶ��
PFTW3_1: Byte;
PFTW3_2: Byte;
PFTW3_3: Byte;
PFTW3_4: Byte;

//RAM Prefile2�Ĵ��� ��ַ��0x10
//����
RASF3_1: Byte;
RASF3_2: Byte;
//��λ
RPOW3_1: Byte;
RPOW3_2: Byte;
//Ƶ��
RFTW3_1: Byte;
RFTW3_2: Byte;
RFTW3_3: Byte;
RFTW3_4: Byte;

//����Prefile3�Ĵ��� ��ַ��0x11
//����
PASF4_1: Byte;
PASF4_2: Byte;
//��λ
PPOW4_1: Byte;
PPOW4_2: Byte;
//Ƶ��
PFTW4_1: Byte;
PFTW4_2: Byte;
PFTW4_3: Byte;
PFTW4_4: Byte;

//RAM Prefile3�Ĵ��� ��ַ��0x11
//����
RASF4_1: Byte;
RASF4_2: Byte;
//��λ
RPOW4_1: Byte;
RPOW4_2: Byte;
//Ƶ��
RFTW4_1: Byte;
RFTW4_2: Byte;
RFTW4_3: Byte;
RFTW4_4: Byte;

//����Prefile4�Ĵ��� ��ַ��0x12
//����
PASF5_1: Byte;
PASF5_2: Byte;
//��λ
PPOW5_1: Byte;
PPOW5_2: Byte;
//Ƶ��
PFTW5_1: Byte;
PFTW5_2: Byte;
PFTW5_3: Byte;
PFTW5_4: Byte;

//RAM Prefile4�Ĵ��� ��ַ��0x12
//����
RASF5_1: Byte;
RASF5_2: Byte;
//��λ
RPOW5_1: Byte;
RPOW5_2: Byte;
//Ƶ��
RFTW5_1: Byte;
RFTW5_2: Byte;
RFTW5_3: Byte;
RFTW5_4: Byte;

//����Prefile5�Ĵ��� ��ַ��0x13
//����
PASF6_1: Byte;
PASF6_2: Byte;
//��λ
PPOW6_1: Byte;
PPOW6_2: Byte;
//Ƶ��
PFTW6_1: Byte;
PFTW6_2: Byte;
PFTW6_3: Byte;
PFTW6_4: Byte;

//RAM Prefile5�Ĵ��� ��ַ��0x13
//����
RASF6_1: Byte;
RASF6_2: Byte;
//��λ
RPOW6_1: Byte;
RPOW6_2: Byte;
//Ƶ��
RFTW6_1: Byte;
RFTW6_2: Byte;
RFTW6_3: Byte;
RFTW6_4: Byte;

//����Prefile6�Ĵ��� ��ַ��0x14
//����
PASF7_1: Byte;
PASF7_2: Byte;
//��λ
PPOW7_1: Byte;
PPOW7_2: Byte;
//Ƶ��
PFTW7_1: Byte;
PFTW7_2: Byte;
PFTW7_3: Byte;
PFTW7_4: Byte;

//RAM Prefile6�Ĵ��� ��ַ��0x14
//����
RASF7_1: Byte;
RASF7_2: Byte;
//��λ
RPOW7_1: Byte;
RPOW7_2: Byte;
//Ƶ��
RFTW7_1: Byte;
RFTW7_2: Byte;
RFTW7_3: Byte;
RFTW7_4: Byte;

//����Prefile7�Ĵ��� ��ַ��0x15
//����
PASF8_1: Byte;
PASF8_2: Byte;
//��λ
PPOW8_1: Byte;
PPOW8_2: Byte;
//Ƶ��
PFTW8_1: Byte;
PFTW8_2: Byte;
PFTW8_3: Byte;
PFTW8_4: Byte;

//RAM Prefile7�Ĵ��� ��ַ��0x15
//����
RASF8_1: Byte;
RASF8_2: Byte;
//��λ
RPOW8_1: Byte;
RPOW8_2: Byte;
//Ƶ��
RFTW8_1: Byte;
RFTW8_2: Byte;
RFTW8_3: Byte;
RFTW8_4: Byte;

//RAM�Ĵ��� ��ַ��0x16

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
