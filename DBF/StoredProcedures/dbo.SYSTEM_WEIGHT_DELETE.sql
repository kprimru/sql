USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 06.11.2008
��������:	  ������� �������� ����� 
                �������� ����������
*/

CREATE PROCEDURE [dbo].[SYSTEM_WEIGHT_DELETE] 
	@swid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SystemWeightTable
	WHERE SW_ID = @swid

	SET NOCOUNT OFF
END