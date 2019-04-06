USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 20.11.2008
��������:	  �������� ������ � ���� ������������
               � ��������� �����
*/

CREATE PROCEDURE [dbo].[PRICE_GROUP_EDIT] 
	@id SMALLINT,
	@name VARCHAR(50),	
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PriceGroupTable 
	SET PG_NAME = @name,
		PG_ACTIVE = @active
	WHERE PG_ID = @id

	SET NOCOUNT OFF
END
