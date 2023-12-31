module shootinggame(
output reg [7:0] R_color,//顯示紅色燈
output reg [7:0] G_color, //顯示綠色燈
output reg [7:0] B_color, //顯示藍色燈
output reg [3:0] column, //顯示燈亮的排
output reg [3:0] a_life, //A玩家生命
output reg [3:0] b_life,//B玩家生命
output reg[6:0] seg, output reg dot, output reg [1:0]COM,//七段顯示器(子彈數量限制)
input a_up,a_down,a_left,a_right, //A玩家的移動(上下左右)
input b_up,b_down,b_left,b_right, //B玩家的移動(上下左右)
input MSB_in, CLK, Clear, //clear 初始值所有變數
input a_attack,a_defense, //A玩家的攻擊(a_attack)和防禦(a_defense)
input b_attack,b_defense//B玩家的攻擊(b_attack)和防禦(b_defense)

);
	wire [3:0] columnA; //A玩家的排數
	wire [3:0] columnB; //B玩家的排數
	wire [7:0] A_type; //A玩家的位置
	wire [7:0] B_type; //B玩家的位置
//我們的攻擊會有上跟下兩顆子彈,所以有up跟down
	wire [7:0] a_attack_type_up;
	wire [7:0] b_attack_type_up;
	wire [7:0] a_attack_type_down;
	wire [7:0] b_attack_type_down;
//module skill的output
	wire [3:0] Alife; //A的生命值
	wire [3:0] Blife; //B的生命值
	wire [3:0] a_attack_column; //A的子彈排數
	wire [3:0] b_attack_column; //B的子彈排數
	wire [7:0] a_defense_type; //A的防禦排數
	wire [7:0] b_defense_type; //B的防禦排數
	wire [3:0] cc; //A攻擊的頻率
	wire [3:0] ccb; //B攻擊的頻率
	
	wire [3:0] a_attack_times;//A攻擊的次數
	wire [3:0] b_attack_times;//B攻擊的次數
	
//宣告副程式	
	divfreq F0(CLK, CLK_div);
	divfreq2 F1(CLK, CLK_div2);
	divfreq3 F2(CLK, CLK_div3);
	divfreq4 F3(CLK,CLK_div4);
	amodule F4(a_up,a_down,a_left,a_right,CLK_div,MSB_in,Clear,A_type,columnA);
	bmodule F5(b_up,b_down,b_right,b_left,CLK_div2,MSB_in,Clear,B_type,columnB);
	skill F6(a_attack,a_defense,b_attack,b_defense,Clear,CLK_div,A_type,B_type,
	columnA,columnB,
	a_attack_type_up,a_attack_type_down,
	b_attack_type_up,b_attack_type_down,
	Alife,Blife,a_attack_column,b_attack_column,
	a_defense_type,b_defense_type,cc,ccb,a_attack_times,b_attack_times);
	//count會隨著clock變動，再由count驅使column的交替顯示
	reg [3:0] count;
//初始的樣子(像右圖那樣)
	initial 
	begin
		count<=4'b0000;
		R_color<=8'b01111111; 
		G_color<=8'b11111110;
		B_color<=8'b11111111;
		column<=4'b1100;
		a_life<=4'b1111;
		b_life<=4'b1111;
		seg <= 7'b1111110;
		dot <= 1'b0;
		COM <= 2'b01;
	end
	
	always @(posedge CLK_div3,posedge Clear) //當CLK_div3或是Clear被正驅動時,做下列事情
		begin
		if(Clear) //當Clear為1,回到初始的樣子
			begin
				R_color<=8'b01111111;
				G_color<=8'b11111110;
				B_color<=8'b11111111;
				column<=4'b1100;
				a_life<=4'b1111;
				b_life<=4'b1111;
				seg <= 7'b1111110;
				dot <= 1'b0;
				COM <= 2'b01;
			end
//當a和b玩家都還沒死掉
		else if((a_life>0)&&(b_life>0))
			begin
				if(COM == 2'b01)
					begin
						case(a_attack_times)
							4'b0000: seg=7'b0000001;
							4'b0001: seg=7'b1001111;
							4'b0010: seg=7'b0010010;
							4'b0011: seg=7'b0000110;
							4'b0100: seg=7'b1001100;
							4'b0101: seg=7'b0100100;
							4'b0110: seg=7'b0100000;
							4'b0111: seg=7'b0001111;
							4'b1000: seg=7'b0000000;
							4'b1001: seg=7'b0000100;
							default: seg=7'b1111110;
						endcase
					COM = 2'b10;
					end
				else
					begin
						case(b_attack_times)
							4'b0000: seg=7'b0000001;
							4'b0001: seg=7'b1001111;
							4'b0010: seg=7'b0010010;
							4'b0011: seg=7'b0000110;
							4'b0100: seg=7'b1001100;
							4'b0101: seg=7'b0100100;
							4'b0110: seg=7'b0100000;
							4'b0111: seg=7'b0001111;
							4'b1000: seg=7'b0000000;
							4'b1001: seg=7'b0000100;
							default: seg=7'b1111110;
						endcase
						COM = 2'b01;
					end
				//CLK_div3變成1,count就加一
				count <= count + 1'b1;
				//當count>=8時,count變為零(count從0到8循環)
				if(count>=4'b1000)
					count<=4'b0000;
				//當count為0時,顯示出a的位置,還有顯示A,B當時的生命
				else if(count==4'b0000)
					begin
						column <= columnA;
						R_color<=A_type;
						G_color<=8'b11111111;
						B_color<=8'b11111111;
						a_life<=Alife;
						b_life<=Blife;
					end
//當count為1時,顯示出b的位置,還有顯示A,B當時的生命
				else if(count==4'b0001)
					begin
						column <= columnB;
						R_color<=8'b11111111;
						G_color<=B_type;
						B_color<=8'b11111111;
						a_life<=Alife;
						b_life<=Blife;
					end
//當count為2時,顯示出a往上射的子彈的位置,還有顯示A,B當時的生命
				else if(count==4'b0010)
					begin
						column <= a_attack_column;
						R_color<=8'b11111111;
						G_color<=8'b11111111;
						B_color<=a_attack_type_up;
						a_life<=Alife;
						b_life<=Blife;
							
					end
//當count為3時,顯示出b往上射子彈的位置,還有顯示A,B當時的生命
				else if(count==4'b0011)
					begin
						column <= columnB;
						R_color<=8'b11111111;
						G_color<=8'b11111111;
						B_color<=b_attack_type_up;
						a_life<=Alife;
						b_life<=Blife;
					end
//當count為4時,顯示出a往下射的子彈的位置,還有顯示A,B當時的生命
				else if(count==4'b0100)
					begin
						column <= a_attack_column;
						R_color<=8'b11111111;
						G_color<=8'b11111111;
						B_color<=a_attack_type_down;
						a_life<=Alife;
						b_life<=Blife;
					end
//當count為5時,顯示出b往下射的子彈的位置,還有顯示A,B當時的生命
				else if(count==4'b0101)
					begin
						column <= b_attack_column;
						R_color<=8'b11111111;
						G_color<=b_attack_type_down;
						B_color<=b_attack_type_down;
						a_life<=Alife;
						b_life<=Blife;
					end
//當count為6時,顯示出a的位置,還有顯示A,B當時的生命
				else if(count==4'b0110)
					begin
//當a防禦時,顯示a防禦的樣子(白色),還有顯示A,B當時的生命
						if(a_defense==1'b1)
							begin
								column <= columnA;
								R_color<=A_type;
								G_color<=A_type;
								B_color<=A_type;
								a_life<=Alife;
								b_life<=Blife;
						  end
//當a沒有防禦時,顯示a的位置(紅色),還有顯示A,B當時的生命
						else if(a_defense==1'b0)
							begin
								column <= columnA;
								R_color<=A_type;
								G_color<=8'b11111111;
								B_color<=8'b11111111;
								a_life<=Alife;
								b_life<=Blife;
							end
					end
//當count為7時,顯示出b的位置,還有顯示A,B當時的生命
				else if(count==4'b0111)
					begin		
//當b防禦時,顯示b防禦的樣子(白色),還有顯示A,B當時的生命
						if(b_defense==1'b1)
							begin
								column <= columnB;
								R_color<=B_type;
								G_color<=B_type;
								B_color<=B_type;
								a_life<=Alife;
								b_life<=Blife;
							end
//當b沒有防禦時,顯示b的位置(綠色),還有顯示A,B當時的生命
						else if(b_defense==1'b0)
							begin
								column <= columnB;
								R_color<=8'b11111111;
								G_color<=B_type;
								B_color<=8'b11111111;
								a_life<=Alife;
								b_life<=Blife;
							end
							
					end
					
					
				end
			//如果a先死掉,顯示綠色的W(右圖)
			else if((a_life==0)&&(b_life>0))
				begin
					if(COM == 2'b01)
						begin
							case(a_attack_times)
								4'b0000: seg=7'b0000001;
								4'b0001: seg=7'b1001111;
								4'b0010: seg=7'b0010010;
								4'b0011: seg=7'b0000110;
								4'b0100: seg=7'b1001100;
								4'b0101: seg=7'b0100100;
								4'b0110: seg=7'b0100000;
								4'b0111: seg=7'b0001111;
								4'b1000: seg=7'b0000000;
								4'b1001: seg=7'b0000100;
								default: seg=7'b1111110;
							endcase
						COM = 2'b10;
						end
					else
						begin
							case(b_attack_times)
								4'b0000: seg=7'b0000001;
								4'b0001: seg=7'b1001111;
								4'b0010: seg=7'b0010010;
								4'b0011: seg=7'b0000110;
								4'b0100: seg=7'b1001100;
								4'b0101: seg=7'b0100100;
								4'b0110: seg=7'b0100000;
								4'b0111: seg=7'b0001111;
								4'b1000: seg=7'b0000000;
								4'b1001: seg=7'b0000100;
								default: seg=7'b1111110;
							endcase
							COM = 2'b01;
						end
					count <= count + 1'b1;
				  if(count>4'b1111)
					count<=4'b1000;
				  else if(count==4'b1000) 
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1001)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11110111;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1010)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b00101011;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1011)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11000000;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1100)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11000000;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1101)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b00111011;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1110)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111100;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1111)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b11111111;
					end
				end
//如果b先死掉,顯示紅色的W(右圖)
			else if((b_life==0)&&(a_life>0))
				begin
					if(COM == 2'b01)
						begin
							case(a_attack_times)
								4'b0000: seg=7'b0000001;
								4'b0001: seg=7'b1001111;
								4'b0010: seg=7'b0010010;
								4'b0011: seg=7'b0000110;
								4'b0100: seg=7'b1001100;
								4'b0101: seg=7'b0100100;
								4'b0110: seg=7'b0100000;
								4'b0111: seg=7'b0001111;
								4'b1000: seg=7'b0000000;
								4'b1001: seg=7'b0000100;
								default: seg=7'b1111110;
							endcase
						COM = 2'b10;
						end
					else
						begin
							case(b_attack_times)
								4'b0000: seg=7'b0000001;
								4'b0001: seg=7'b1001111;
								4'b0010: seg=7'b0010010;
								4'b0011: seg=7'b0000110;
								4'b0100: seg=7'b1001100;
								4'b0101: seg=7'b0100100;
								4'b0110: seg=7'b0100000;
								4'b0111: seg=7'b0001111;
								4'b1000: seg=7'b0000000;
								4'b1001: seg=7'b0000100;
								default: seg=7'b1111110;
							endcase
							COM = 2'b01;
						end

					count <= count + 1'b1;
				  if(count>4'b1111)
					count<=4'b1000;
				  else if(count==4'b1000) 
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b11111111;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1001)
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b11111100;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1010)
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b00111011;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1011)
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b11000000;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1100)
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b11000000;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1101)
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b00101011;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1110)
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b11110111;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1111)
					begin
					 column<=count;
					 G_color<=8'b11111111;
					 R_color<=8'b11111111;
					 B_color<=8'b11111111;
					end
				end
//如果一起死掉(平手),顯示藍色的雞你太美(右圖)
			else if((b_life==0)&&(a_life==0))
				 begin
					if(COM == 2'b01)
						begin
							case(a_attack_times)
								4'b0000: seg=7'b0000001;
								4'b0001: seg=7'b1001111;
								4'b0010: seg=7'b0010010;
								4'b0011: seg=7'b0000110;
								4'b0100: seg=7'b1001100;
								4'b0101: seg=7'b0100100;
								4'b0110: seg=7'b0100000;
								4'b0111: seg=7'b0001111;
								4'b1000: seg=7'b0000000;
								4'b1001: seg=7'b0000100;
								default: seg=7'b1111110;
							endcase
						COM = 2'b10;
						end
					else
						begin
							case(b_attack_times)
								4'b0000: seg=7'b0000001;
								4'b0001: seg=7'b1001111;
								4'b0010: seg=7'b0010010;
								4'b0011: seg=7'b0000110;
								4'b0100: seg=7'b1001100;
								4'b0101: seg=7'b0100100;
								4'b0110: seg=7'b0100000;
								4'b0111: seg=7'b0001111;
								4'b1000: seg=7'b0000000;
								4'b1001: seg=7'b0000100;
								default: seg=7'b1111110;
							endcase
							COM = 2'b01;
						end
				  count <= count + 1'b1;
				  if(count>4'b1111)
					count<=4'b1000;
				  else if(count==4'b1000) 
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b11111111;
					end
				  else if(count==4'b1001)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b11001111;
					end
				  else if(count==4'b1010)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b11000111;
					end
				  else if(count==4'b1011)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b10111011;
					end
				  else if(count==4'b1100)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b01000000;
					end
				  else if(count==4'b1101)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b00000000;
					end
				  else if(count==4'b1110)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b11111011;
					end
				  else if(count==4'b1111)
					begin
					 column<=count;
					 R_color<=8'b11111111;
					 G_color<=8'b11111111;
					 B_color<=8'b11100111;
					end
				 end
		end	
endmodule

//a's mod
module amodule(input a_up,a_down,a_left,a_right,CLK_div,MSB_in,Clear, output reg [7:0] A_type,output reg [3:0] columnA);
	skill F6(a_attack,a_defense,b_attack,b_defense,Clear,CLK_div,A_type,B_type,a_attack_type,b_attack_type,Alife,Blife,a_attack_column,b_attack_column,a_defense_type,b_defense_type,cc,ccb);
	initial
		A_type=8'b01111111;
	always @(posedge CLK_div,posedge Clear)
	begin
		if(Clear)
//設定a的初始值
	begin
				A_type<=8'b01111111;
				columnA<=4'b1100;
			end
		else
			begin
				//a's move 往上
				if(a_up == 1'b1)
					begin
						if(A_type == 8'b11111110) //碰到邊邊就停
							A_type<=A_type;
						else
							A_type <= {MSB_in,A_type[7:1]};//利用shifting
					end
				//a's move 往下
				else if(a_down == 1'b1)
					begin
						if(A_type == 8'b01111111) //碰到邊邊就停
							A_type <= A_type;
						else
							A_type <= {A_type[6:0],MSB_in}; //利用shifting
					end
//a's move 往左
				if(a_left == 1'b1)
					begin
						if(columnA==4'b1000)
							columnA <= columnA ; //碰到邊邊就停
						else
							columnA <= columnA - 1'b1; //往左就多一位元排數
					end
//a's move 往右
				else if(a_right == 1'b1)
					begin
						if(columnA==4'b1111)
							columnA <= columnA ; //碰到邊邊就停
						else
							columnA <= columnA + 1'b1; //往右就少一位元排數

					end
			end
			
			
	end
endmodule
//b's mod
module bmodule(input b_up,b_down,b_right,b_left,CLK_div2,MSB_in,Clear, output reg [7:0] B_type,output reg [3:0] columnB);
	skill F6(a_attack,a_defense,b_attack,b_defense,Clear,CLK_div,A_type,B_type,a_attack_type,b_attack_type,Alife,Blife,a_attack_column,b_attack_column,a_defense_type,b_defense_type,cc,ccb);
	initial
		B_type=8'b01111111;
	always @(posedge CLK_div2,posedge Clear)
	begin
		if(Clear)
//設定b的初始值
			begin
				B_type<=8'b11111110;
				columnB<=4'b1100;
			end
		else
			begin
				//b's move 往上
				if(b_up == 1'b1)
					begin
						if(B_type == 8'b11111110)
							B_type<=B_type; //碰到邊邊就停
						else
							B_type <= {MSB_in,B_type[7:1]}; //利用shifting
					end
//b's move 往下
				else if(b_down == 1'b1)
					begin
						if(B_type == 8'b01111111)
							B_type <= B_type; //碰到邊邊就停
						else
							B_type <= {B_type[6:0],MSB_in}; //利用shifting
					end
				//b's move 往左
if(b_left == 1'b1)
					begin
						if(columnB==4'b1000)
								columnB <= columnB ; //碰到邊邊就停
						else
							columnB <= columnB - 1'b1; //往左就多一位元排數
					end
				//b's move 往右
				else if(b_right == 1'b1)
					begin
						if(columnB==4'b1111)
							columnB <= columnB ; //碰到邊邊就停
						else	
							columnB <= columnB + 1'b1;	//往右就少一位元排數
					end
			end
	end
endmodule
//攻擊防禦
module skill(

input a_attack,a_defense,
input b_attack,b_defense,
input Clear,CLK_div4,
input [7:0] A_type,
input [7:0] B_type,
input [3:0]	columnA,
input [3:0]	columnB,
output reg [7:0] a_attack_type_up,
output reg [7:0] a_attack_type_down,
output reg [7:0] b_attack_type_up,
output reg [7:0] b_attack_type_down,
output reg [3:0] Alife,
output reg [3:0] Blife,
output reg [3:0] a_attack_column,
output reg [3:0] b_attack_column,
output reg [7:0] a_defense_type,
output reg [7:0] b_defense_type,
output reg [3:0] cc, //A攻擊的頻率
output reg [3:0] ccb, //B攻擊的頻率
output reg [3:0] a_attack_times,//各九枚子彈
output reg [3:0] b_attack_times
);
		
		
		initial
		begin
			a_attack_type_up<=8'b11111111;
			b_attack_type_up<=8'b11111111;
			a_attack_type_down<=8'b11111111;
			b_attack_type_down<=8'b11111111;
			a_attack_column<=columnA;
			b_attack_column<=columnB;
			Alife<=4'b1111;
			Blife<=4'b1111;
			cc<=4'b0;
			ccb<=4'b0;
			a_attack_times <= 4'b1001;//各九枚子彈
			b_attack_times <= 4'b1001;
		end
		always @(posedge CLK_div4,posedge Clear)
		begin
		//Clear=1時,沒有子彈出現
		if(Clear)
			begin
				a_attack_type_up<=8'b11111111;
				b_attack_type_up<=8'b11111111;
				a_attack_type_down<=8'b11111111;
				b_attack_type_down<=8'b11111111;
				a_attack_column<=columnA;
				b_attack_column<=columnB;
				Alife<=4'b1111;
				Blife<=4'b1111;
				cc<=4'b0;
				ccb<=4'b0;
				a_attack_times <= 4'b1001;//各九枚子彈
				b_attack_times <= 4'b1001;
			end
		else
			begin
				Alife<=Alife;
				Blife<=Blife;
			if(a_attack==1'b1 && a_attack_times > 4'b0000)
				begin
//這個部分的cc是為了,讓每個人一次只能射一發攻擊,等到子彈碰到邊界才能在發射一顆
					if(cc==0&&Alife>0&&Blife>0)a_attack_times = a_attack_times - 1'b1;
					if(cc==0)
						begin
							a_attack_type_up<={1'b1,a_attack_type_up[7:1]}+{1'b1,A_type[7:1]}+1; //a子彈往上

							a_attack_type_down<={a_attack_type_down[6:0],1'b1}+{A_type[6:0],1'b1}+1;	//a子彈往下

							a_attack_column<=columnA; //a子彈和a發射出去的排數一樣
						end
					
					cc<=cc+1;
					if(cc==4'b0111)
						cc<=4'b0000;
				end
			else if(a_attack==1'b0) //當按了攻擊紐，並且cc=0時，子彈才可以發射
				begin
					if(cc!=0)
						cc<=cc+1;
					if(cc>=4'b0111)
						cc<=4'b0000;
					a_attack_type_up<={1'b1,a_attack_type_up[7:1]};
					a_attack_type_down<={a_attack_type_down[6:0],1'b1};
				end
//如果a攻擊到b(往上)
			if((a_attack_type_up==B_type)&&(a_attack_column==columnB))
				begin
					//b有防禦到的話,不扣血
					if(b_defense==1'b1)
						begin
									Blife<=Blife;
						end
					//沒有的話,血量少一格
					else
						begin
							Blife<=Blife/2;
						end
				end		
//如果a攻擊到b(往下)
			if((a_attack_type_down==B_type)&&(a_attack_column==columnB))
				begin
//b有防禦到的話,不扣血
					if(b_defense==1'b1)
						begin
							Blife<=Blife;
						end
					//沒有的話,血量少一格
else
						Blife<=Blife/2;
				end					
			if(b_attack==1'b1 && b_attack_times > 4'b0000)
				begin
//這個部分的ccb也是為了,讓每個人一次只能射一發攻擊,等到子彈碰到邊界才能在發射一顆
					if(ccb==0&&Alife>0&&Blife>0)b_attack_times = b_attack_times - 1'b1;
					if(ccb==0)
						begin
							b_attack_type_up<={1'b1,b_attack_type_up[7:1]}+{1'b1,B_type[7:1]}+1;
							b_attack_type_down<={b_attack_type_down[6:0],1'b1}+{B_type[6:0],1'b1}+1;
							b_attack_column<=columnB;
							if(ccb!=0)
								ccb<=ccb+1;
							if(ccb>=4'b0111)
								ccb<=4'b0000;
						end
					ccb<=ccb+1;
				end
			else if(b_attack==1'b0) //當按了攻擊紐，並且ccb=0時，子彈才可以發射

				begin
					if(ccb!=0)
						ccb<=ccb+1;
					if(ccb>=4'b0111)
							ccb<=4'b0000;
					b_attack_type_up<={1'b1,b_attack_type_up[7:1]};
					b_attack_type_down<={b_attack_type_down[6:0],1'b1};
				end
//如果b攻擊到a(往下)
			if((b_attack_type_down==A_type)&&(b_attack_column==columnA))
				begin
//a有防禦到的話,不扣血
					if(a_defense==1'b1)
						begin
							Alife<=Alife;
						end
					//沒有的話,血量少一格
					else 
						begin
							Alife<=Alife/2;
						end
				end
//如果b攻擊到a(往上)
			if((b_attack_type_up==A_type)&&(b_attack_column==columnA))
				begin
					//a有防禦到的話,不扣血
					if(a_defense==1'b1)
						Alife<=Alife;
					//沒有的話,血量少一格
					else 
						Alife<=Alife/2;
				end
		end
	end
endmodule



//a顯示頻率
module divfreq(input CLK, output reg CLK_div);
	reg [24:0] Count;
	always @(posedge CLK)
	begin
	if(Count > 10000000)
		begin
			Count <= 25'b0;
			CLK_div <= ~CLK_div;
		end
	else
		Count <= Count + 1'b1;
	end
endmodule

//b顯示頻率
module divfreq2(input CLK, output reg CLK_div2);
	reg [24:0] Count1;
	always @(posedge CLK)
	begin
	if(Count1 > 10000000)
		begin
			Count1 <= 25'b0;
			CLK_div2 <= ~CLK_div2;
		end
	else
		Count1 <= Count1 + 1'b1;
	end
endmodule
//主程式頻率

module divfreq3(input CLK, output reg CLK_div3);
	reg [24:0] Count3;
	always @(posedge CLK)
	begin
	if(Count3 > 10000)
		begin
			Count3 <= 25'b0;
			CLK_div3 <= ~CLK_div3;
		end
	else
		Count3 <= Count3 + 1'b1;
	end
endmodule
//skill 顯示頻率
module divfreq4(input CLK, output reg CLK_div4);
	reg [24:0] Count4;
	always @(posedge CLK)
	begin
	if(Count4 > 1500000)
		begin
			Count4 <= 25'b0;
			CLK_div4 <= ~CLK_div4;
		end
	else
		Count4 <= Count4 + 1'b1;
	end
endmodule
