USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Автор:		  Денисов Алексей
-- Дата создания: 25.08.2008
-- Описание:	  Делает проверку ИНН по контрольной сумме
-- =============================================

ALTER FUNCTION [dbo].[INN_CHECK]
(
	@str varchar(15)
)
RETURNS int
AS
BEGIN
DECLARE @R int
DECLARE @I int
DECLARE @Num int
DECLARE @StrNum Varchar(15)
DECLARE @CheckSumm int
DECLARE @L int
Set @R = 1
Set @StrNum = @Str
Set @L =  LEN (@Str)
-- Проверка длины ИНН
if @L=0
BEGIN
	Set @R = 2
	RETURN @R
END
if (@L = 11) or (@L < 10) or (@L > 12)
BEGIN
	Set @R = 0
	RETURN @R
END
-- ИНН 10 знаков
if @L = 10
BEGIN
	Set @I = 1
	Set @CheckSumm = 0
	WHILE @I < 10
	BEGIN
		Set @Num = Convert(int, SUBSTRING (@StrNum, 1, 1))
		Set @StrNum = SUBSTRING (@StrNum, 2, @L)
		if @I = 1
			Set @CheckSumm = @CheckSumm + @Num * 2 	
		if @I = 2
			Set @CheckSumm = @CheckSumm + @Num * 4 	
		if @I = 3
			Set @CheckSumm = @CheckSumm + @Num * 10 	
		if @I = 4
			Set @CheckSumm = @CheckSumm + @Num * 3 	
		if @I = 5
			Set @CheckSumm = @CheckSumm + @Num * 5 	
		if @I = 6
			Set @CheckSumm = @CheckSumm + @Num * 9 	
		if @I = 7
			Set @CheckSumm = @CheckSumm + @Num * 4 	
		if @I = 8
			Set @CheckSumm = @CheckSumm + @Num * 6 	
		if @I = 9
			Set @CheckSumm = @CheckSumm + @Num * 8 	
		Set @I = @I + 1
	END
	Set @Num = @CheckSumm % 11
	if @Num = 10
		Set @Num = 0
	if not(@Num = Convert(int, SUBSTRING (@StrNum, 1, 1)))
	BEGIN
		Set @R = 0
		RETURN @R
	END
END
-- ИНН 12 знаков
if @L = 12
BEGIN
	Set @I = 1
	Set @CheckSumm = 0
	WHILE @I < 11
	BEGIN
	Set @Num = Convert(int, SUBSTRING (@StrNum, 1, 1))
	Set @StrNum = SUBSTRING (@StrNum, 2, @L)
	if @I = 1
		Set @CheckSumm = @CheckSumm + @Num * 7 	
	if @I = 2
		Set @CheckSumm = @CheckSumm + @Num * 2 	
	if @I = 3
		Set @CheckSumm = @CheckSumm + @Num * 4 	
	if @I = 4
		Set @CheckSumm = @CheckSumm + @Num * 10 	
	if @I = 5
		Set @CheckSumm = @CheckSumm + @Num * 3	
	if @I = 6
		Set @CheckSumm = @CheckSumm + @Num * 5 	
	if @I = 7
		Set @CheckSumm = @CheckSumm + @Num * 9 	
	if @I = 8
		Set @CheckSumm = @CheckSumm + @Num * 4 	
	if @I = 9
		Set @CheckSumm = @CheckSumm + @Num * 6 	
	if @I = 10
		Set @CheckSumm = @CheckSumm + @Num * 8
	Set @I = @I + 1
	END
	Set @Num = @CheckSumm % 11
	if @Num = 10
		Set @Num = 0
	if not(@Num = Convert(int, SUBSTRING (@StrNum, 1, 1)))
	BEGIN
		Set @R = 0
		RETURN @R
	END

	Set @StrNum = @Str
	Set @I = 1
	Set @CheckSumm = 0
	WHILE @I < 12
	BEGIN
	Set @Num = Convert(int, SUBSTRING (@StrNum, 1, 1))
	Set @StrNum = SUBSTRING (@StrNum, 2, @L)
	if @I = 1
		Set @CheckSumm = @CheckSumm + @Num * 3 	
	if @I = 2
		Set @CheckSumm = @CheckSumm + @Num * 7 	
	if @I = 3
		Set @CheckSumm = @CheckSumm + @Num * 2 	
	if @I = 4
		Set @CheckSumm = @CheckSumm + @Num * 4 	
	if @I = 5
		Set @CheckSumm = @CheckSumm + @Num * 10	
	if @I = 6
		Set @CheckSumm = @CheckSumm + @Num * 3 	
	if @I = 7
		Set @CheckSumm = @CheckSumm + @Num * 5	
	if @I = 8
		Set @CheckSumm = @CheckSumm + @Num * 9 	
	if @I = 9
		Set @CheckSumm = @CheckSumm + @Num * 4 	
	if @I = 10
		Set @CheckSumm = @CheckSumm + @Num * 6
	if @I = 11
		Set @CheckSumm = @CheckSumm + @Num * 8
	Set @I = @I + 1
	END
	Set @Num = @CheckSumm % 11
	if @Num = 10
		Set @Num = 0
	if not(@Num = Convert(int, SUBSTRING (@StrNum, 1, 1)))
	BEGIN
		Set @R = 0
		RETURN @R
	END
END
RETURN @R
END
