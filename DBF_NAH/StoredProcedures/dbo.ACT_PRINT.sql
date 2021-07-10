USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
�����:
���� ��������:  
��������:
*/
ALTER PROCEDURE [dbo].[ACT_PRINT]
	@actid INT,
	@contract INT = NULL,
	@group BIT = 0,
	@apply BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	EXEC dbo.ACT_PRINT_BY_ID_LIST @actid, 0, @contract, @group, @apply
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT] TO rl_act_p;
GO