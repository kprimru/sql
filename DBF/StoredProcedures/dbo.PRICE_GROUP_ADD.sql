USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  �������� ��� ������������ � 
               ����������
*/

CREATE PROCEDURE [dbo].[PRICE_GROUP_ADD] 
	@name VARCHAR(50),	
	@active BIT = 1,  
	@returnvalue BIT = 1  
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.PriceGroupTable(PG_NAME, PG_ACTIVE) 
	VALUES (@name, @active)
	
	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
