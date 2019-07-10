USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:		  ������� �������
���� ��������: 10.05.2012
��������:	  �������� ������� � ����������
*/
CREATE PROCEDURE [dbo].[QUARTER_ADD] 
	@name	VARCHAR(50),
	@begin	SMALLDATETIME,
	@end	SMALLDATETIME,
	@active BIT = 1,
	@returnvalue BIT = 1  
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.Quarter(
			QR_NAME, QR_BEGIN, QR_END, QR_ACTIVE) 
	VALUES (@NAME, @begin, @end, @active)

	IF @returnvalue = 1
	  SELECT SCOPE_IDENTITY() AS NEW_IDEN
END
