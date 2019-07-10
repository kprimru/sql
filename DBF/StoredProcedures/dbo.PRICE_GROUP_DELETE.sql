USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  ������� ��� ������������ � 
               ��������� ����� �� �����������
*/

CREATE PROCEDURE [dbo].[PRICE_GROUP_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.PriceGroupTable 
	WHERE PG_ID = @id

	SET NOCOUNT OFF
END
