USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	
/*
�����:		  ������� �������
���� ��������: 18.12.2008
��������:	  �������� ��������� ������� 
               � ��������� ����������� �� 
               ��������� ������ � ��������� 
               ����������
*/

CREATE PROCEDURE [dbo].[PRICE_SYSTEM_ADD]  
	@pricetypeid SMALLINT, 
	@periodid SMALLINT,
	@systemid SMALLINT,
	@price MONEY,
	@pgdid SMALLINT,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	IF @pgdid IS NOT NULL	
		INSERT INTO dbo.PriceSystemTable(PS_ID_PERIOD, PS_ID_TYPE, PS_ID_PGD, PS_PRICE)
		VALUES (@periodid, @pricetypeid, @pgdid, @price)
	ELSE
		INSERT INTO dbo.PriceSystemTable(PS_ID_PERIOD, PS_ID_TYPE, PS_ID_SYSTEM, PS_PRICE)
		VALUES (@periodid, @pricetypeid, @systemid, @price)

	IF @returnvalue = 1
	  SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END