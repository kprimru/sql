USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:			%authorname%
Дата создания:	03.02.2009
Описание:		Исключить дистрибутив
				из договора
*/

ALTER PROCEDURE [dbo].[DISTRS_CONTRACT_DELETE]
	@cd_id INT
AS
BEGIN
	SET NOCOUNT ON

		DELETE	FROM dbo.ContractDistrTable
		WHERE	COD_ID = @cd_id

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[DISTRS_CONTRACT_DELETE] TO rl_client_contract_w;
GO