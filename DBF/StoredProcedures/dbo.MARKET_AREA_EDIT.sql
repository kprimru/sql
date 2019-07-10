USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 05.11.2008
��������:	  �������� ������ � �������� 
               ���������� � ��������� �����
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_EDIT] 
	@marketareaid INT,
	@marketareaname VARCHAR(100),
	@marketareashortname VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.MarketAreaTable 
	SET MA_NAME = @marketareaname, 
		MA_SHORT_NAME = @marketareashortname,
		MA_ACTIVE = @active
	WHERE MA_ID = @marketareaid

	SET NOCOUNT OFF
END