USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			%authorname%
���� ��������:	03.02.2009
��������:		��������� �����������
				�� ��������
*/

CREATE PROCEDURE [dbo].[DISTRS_CONTRACT_DELETE]
	@cd_id INT
AS
BEGIN
	SET NOCOUNT ON

		DELETE	FROM dbo.ContractDistrTable
		WHERE	COD_ID = @cd_id

	SET NOCOUNT OFF
END