USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Salary].[ServiceDetail]
(
        [ID]                   UniqueIdentifier      NOT NULL,
        [ID_SALARY]            UniqueIdentifier      NOT NULL,
        [ID_CLIENT]            Int                   NOT NULL,
        [CL_NAME]              VarChar(500)          NOT NULL,
        [TO_ID]                Int                   NOT NULL,
        [TO_NAME]              VarChar(500)          NOT NULL,
        [ID_CITY]              SmallInt              NOT NULL,
        [CT_NAME]              VarChar(150)          NOT NULL,
        [ID_TYPE]              SmallInt              NOT NULL,
        [KGS]                  decimal                   NULL,
        [ID_PERIOD]            SmallInt              NOT NULL,
        [CL_TERR]              VarChar(50)               NULL,
        [CLIENT_TOTAL_PRICE]   Money                     NULL,
        [TO_COUNT]             SmallInt                  NULL,
        [TO_PRICE]             Money                     NULL,
        [CPS_PERCENT]          decimal                   NULL,
        [TO_CALC]              Money                     NULL,
        [CPS_MIN]              Money                     NULL,
        [CPS_MAX]              Money                     NULL,
        [CPS_INET]             Bit                       NULL,
        [CPS_PAY]              Bit                       NULL,
        [CPS_COEF]             Bit                       NULL,
        [CPS_ACT]              Bit                       NULL,
        [SYS_COUNT]            SmallInt                  NULL,
        [KOB]                  decimal                   NULL,
        [PAY]                  Bit                       NULL,
        [CALC]                 Bit                       NULL,
        [NOTE]                 VarChar(Max)              NULL,
        [UPDATES]              Bit                       NULL,
        [ACT]                  Bit                       NULL,
        [INET]                 Bit                       NULL,
        [TO_RESULT]            Money                     NULL,
        [TO_HANDS]             Money                     NULL,
        [TO_PAY_RESULT]        Money                     NULL,
        [TO_PAY_HANDS]         Money                     NULL,
        [HOLD]                 Bit                       NULL,
        [TO_RANGE]             decimal                   NULL,
        [TO_SERVICE_COEF]      decimal                   NULL,
        [TO_SERVICE]           VarChar(50)               NULL,
        CONSTRAINT [PK_Salary.ServiceDetail] PRIMARY KEY CLUSTERED ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Salary.ServiceDetail(ID_SALARY,TO_ID,ID_PERIOD)] ON [Salary].[ServiceDetail] ([ID_SALARY] ASC, [TO_ID] ASC, [ID_PERIOD] ASC);
GO
