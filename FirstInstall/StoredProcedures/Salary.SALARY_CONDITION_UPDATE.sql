USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Salary].[SALARY_CONDITION_UPDATE]
	@SC_ID			UNIQUEIDENTIFIER,
	@SC_WEIGHT		DECIMAL(8, 4),
	@SC_VALUE		MONEY,
	@SC_ID_PER_TYPE	UNIQUEIDENTIFIER,
	@SC_DATE		SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @SC_ID_MASTER UNIQUEIDENTIFIER

	SELECT @SC_ID_MASTER = SC_ID_MASTER
	FROM Salary.SalaryConditionDetail
	WHERE SC_ID = @SC_ID

	DECLARE @OLD	VARCHAR(MAX)
	DECLARE @NEW	VARCHAR(MAX)

	EXEC Common.PROTOCOL_VALUE_GET 'SALARY_CONDITION', @SC_ID_MASTER, @OLD OUTPUT


	UPDATE	Salary.SalaryConditionDetail
	SET		SC_WEIGHT		=	@SC_WEIGHT,
			SC_VALUE		=	@SC_VALUE,
			SC_ID_PER_TYPE	=	@SC_ID_PER_TYPE,
			SC_DATE			=	@SC_DATE
	WHERE	SC_ID			=	@SC_ID

	UPDATE	Salary.SalaryCondition
	SET		SCMS_LAST	=	GETDATE()
	WHERE	SCMS_ID	=
		(
			SELECT	SC_ID_MASTER
			FROM	Salary.SalaryConditionDetail
			WHERE	SC_ID	=	@SC_ID
		)

	EXEC Common.PROTOCOL_VALUE_GET 'SALARY_CONDITION', @SC_ID_MASTER, @NEW OUTPUT

	EXEC Common.PROTOCOL_INSERT 'SALARY_CONDITION', '��������������', @SC_ID_MASTER, @OLD, @NEW

END

GO
GRANT EXECUTE ON [Salary].[SALARY_CONDITION_UPDATE] TO rl_salary_condition_u;
GO
