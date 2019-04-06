USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Common].[NumToStr]
(
	@NUM			BIGINT,
	@IS_MALE_GENDER	BIT
)
RETURNS VARCHAR(255)
AS
BEGIN
	DECLARE @nword VARCHAR(255)
	DECLARE @th TINYINT 
	DECLARE @gr SMALLINT 
	DECLARE @d3 TINYINT 
	DECLARE @d2 TINYINT
	DECLARE @d1 TINYINT
	
	IF @Num < 0 
		RETURN '*** ������. ������������� �����' 
	ELSE IF @Num=0 
		RETURN '����'
		
	
	WHILE @Num > 0
	BEGIN
		SET @th = ISNULL(@th, 0) + 1
		SET @gr = @Num % 1000    
		SET @Num = (@Num - @gr) / 1000
		
		IF @gr > 0
		BEGIN
			SET @d3 = (@gr - @gr % 100) / 100
			SET @d1 = @gr % 10
			SET @d2 = (@gr - @d3 * 100 - @d1) / 10
			
			IF @d2 = 1 
				SET @d1 = 10 + @d1
				
			SET @nword = 
				CASE @d3
					WHEN 1 THEN ' ���' 
					WHEN 2 THEN ' ������' 
					WHEN 3 THEN ' ������'
					WHEN 4 THEN ' ���������' 
					WHEN 5 THEN ' �������' 
					WHEN 6 THEN ' ��������'
					WHEN 7 THEN ' �������' 
					WHEN 8 THEN ' ���������' 
					WHEN 9 THEN ' ���������' 
					ELSE '' 
				END +
				CASE @d2
					WHEN 2 THEN ' ��������' 
					WHEN 3 THEN ' ��������' 
					WHEN 4 THEN ' �����'
					WHEN 5 THEN ' ���������' 
					WHEN 6 THEN ' ����������' 
					WHEN 7 THEN ' ���������'
					WHEN 8 THEN ' �����������' 
					WHEN 9 THEN ' ���������' 
					ELSE '' 
				END +
				CASE @d1
					WHEN 1 THEN
						(
							case 
								WHEN @th = 2 OR (@th = 1 AND @IS_MALE_GENDER = 0) THEN ' ����' 
								ELSE ' ����' 
							END)
					WHEN 2 THEN
						(
							CASE 
								WHEN @th = 2 OR (@th = 1 AND @IS_MALE_GENDER = 0) THEN ' ���' 
								ELSE ' ���' 
							END
						)
					WHEN 3 THEN ' ���' 
					WHEN 4 THEN ' ������' 
					WHEN 5 THEN ' ����'
					WHEN 6 THEN ' �����' 
					WHEN 7 THEN ' ����' 
					WHEN 8 THEN ' ������'
					WHEN 9 THEN ' ������' 
					WHEN 10 THEN ' ������' 
					WHEN 11 THEN ' �����������'
					WHEN 12 THEN ' ����������' 
					WHEN 13 THEN ' ����������' 
					WHEN 14 THEN ' ������������'
					WHEN 15 THEN ' ����������' 
					WHEN 16 THEN ' �����������'
					WHEN 17 THEN ' ����������'
					WHEN 18 THEN ' ������������' 
					WHEN 19 THEN ' ������������'
					ELSE '' 
				END +
				CASE @th
					WHEN 2 THEN ' �����' + 
							(
								CASE 
									WHEN @d1 = 1 THEN '�' 
									WHEN @d1 IN (2, 3, 4) THEN '�' 
									ELSE ''   
								END
							)
					WHEN 3 THEN ' �������' 
					WHEN 4 THEN ' ��������' 
					WHEN 5 THEN ' ��������' 
					WHEN 6 THEN ' ����������' 
					WHEN 7 THEN ' ����������'
					ELSE '' 
				END +
				CASE 
					WHEN @th IN (3, 4, 5, 6, 7) THEN 
						(
							CASE
								WHEN @d1 = 1 THEN ''
								WHEN @d1 IN (2, 3, 4) THEN '�' 
								ELSE '��' 
							END
						)						 
					ELSE '' 
				END + ISNULL(@nword, '')
		END
	END
  RETURN UPPER(SUBSTRING(@nword, 2, 1)) + SUBSTRING(@nword, 3, LEN(@nword) - 2)
END