USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:         ������� �������
��������:      ������� ����������� �� ������ ������������� �������
*/

CREATE PROCEDURE [dbo].[CLIENT_DISTR_DELETE] 
	@id INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.ClientDistrTable 
	WHERE CD_ID = @id

	SET NOCOUNT OFF
END


