USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 05.11.2008
��������:	  ������� �� ����������� �������� 
               ���������� � ��������� �����
*/

CREATE PROCEDURE [dbo].[MARKET_AREA_DELETE] 
	@marketareaid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.MarketAreaTable 
	WHERE MA_ID = @marketareaid

	SET NOCOUNT OFF
END