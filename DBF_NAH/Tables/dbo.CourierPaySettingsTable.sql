USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CourierPaySettingsTable]
(
        [CPS_ID]        SmallInt   Identity(1,1)   NOT NULL,
        [CPS_ID_TYPE]   SmallInt                   NOT NULL,
        [CPS_PERCENT]   decimal                        NULL,
        [CPS_MIN]       Money                          NULL,
        [CPS_MAX]       Money                          NULL,
        [CPS_SOURCE]    TinyInt                    NOT NULL,
        [CPS_PAY]       Bit                        NOT NULL,
        [CPS_COEF]      Bit                        NOT NULL,
        [CPS_INET]      TinyInt                        NULL,
        [CPS_FIXED]     Money                          NULL,
        [CPS_ACT]       Bit                            NULL,
        CONSTRAINT [PK_dbo.CourierPaySettingsTable] PRIMARY KEY CLUSTERED ([CPS_ID]),
        CONSTRAINT [FK_dbo.CourierPaySettingsTable(CPS_ID_TYPE)_dbo.ClientTypeTable(CLT_ID)] FOREIGN KEY  ([CPS_ID_TYPE]) REFERENCES [dbo].[ClientTypeTable] ([CLT_ID])
);GO
