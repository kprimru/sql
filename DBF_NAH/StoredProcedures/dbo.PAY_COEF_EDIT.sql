USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  Денисов Алексей
Описание:
*/

ALTER PROCEDURE [dbo].[PAY_COEF_EDIT]
	@id SMALLINT,
	@min SMALLINT,
	@max SMALLINT,
	@value DECIMAL(8, 4),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PayCoefTable
	SET PC_START = @min,
		PC_END = @max,
		PC_VALUE = @value,
		PC_ACTIVE = @active
	WHERE PC_ID = @id

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[PAY_COEF_EDIT] TO rl_pay_coef_w;
GO