import { Box, Button, createStyles, Grid, Modal, Stack, Text } from '@mantine/core';
import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useLocales } from '../../providers/LocaleProvider';
import { fetchNui } from '../../utils/fetchNui';
import type { InputProps } from '../../typings';
import { OptionValue } from '../../typings';
import InputField from './components/fields/input';
import CheckboxField from './components/fields/checkbox';
import SelectField from './components/fields/select';
import NumberField from './components/fields/number';
import SliderField from './components/fields/slider';
import { useFieldArray, useForm } from 'react-hook-form';
import ColorField from './components/fields/color';
import DateField from './components/fields/date';
import TextareaField from './components/fields/textarea';
import TimeField from './components/fields/time';
import dayjs from 'dayjs';
import { cardWrapperSx, cardMainLabelSx, gfx } from '../../theme';

export type FormValues = {
  test: {
    value: any;
  }[];
};

const useStyles = createStyles(() => ({
  // The single card wrapping both the heading (label section) and the form (content section).
  mainWrapper: {
    ...cardWrapperSx,
  },
  labelSection: {
    padding: '14px 18px',
    borderBottom: `1px solid ${gfx.line}`,
    position: 'relative',
    zIndex: 1,
  },
  mainLabel: {
    ...cardMainLabelSx,
    fontSize: 20,
  },
  contentSection: {
    padding: '16px 18px 18px',
    position: 'relative',
    zIndex: 1,
  },
}));

const InputDialog: React.FC = () => {
  const { classes } = useStyles();
  const [fields, setFields] = React.useState<InputProps>({
    heading: '',
    rows: [{ type: 'input', label: '' }],
  });
  const [visible, setVisible] = React.useState(false);
  const { locale } = useLocales();
  const closeTimeout = React.useRef<number | null>(null);

  const form = useForm<{ test: { value: any }[] }>({});
  const fieldForm = useFieldArray({
    control: form.control,
    name: 'test',
  });

  useNuiEvent<InputProps>('openDialog', (data) => {
    if (closeTimeout.current) {
      clearTimeout(closeTimeout.current);
      closeTimeout.current = null;
    }
    form.reset();
    fieldForm.remove();

    setFields(data);
    setVisible(true);
    data.rows.forEach((row, index) => {
      fieldForm.insert(
        index,
        {
          value:
            row.type !== 'checkbox'
              ? row.type === 'date' || row.type === 'date-range' || row.type === 'time'
                ? // Set date to current one if default is set to true
                  row.default === true
                  ? new Date().getTime()
                  : Array.isArray(row.default)
                  ? row.default.map((date) => new Date(date).getTime())
                  : row.default && new Date(row.default).getTime()
                : row.default
              : row.checked,
        } || { value: null }
      );
      // Backwards compat with new Select data type
      if (row.type === 'select' || row.type === 'multi-select') {
        row.options = row.options.map((option) =>
          !option.label ? { ...option, label: option.value } : option
        ) as Array<OptionValue>;
      }
    });
  });

  useNuiEvent('closeInputDialog', () => handleClose(true));

  const handleClose = (dontPost?: boolean) => {
    setVisible(false);
    if (closeTimeout.current) {
      clearTimeout(closeTimeout.current);
    }
    closeTimeout.current = window.setTimeout(() => {
      form.reset();
      fieldForm.remove();
      closeTimeout.current = null;
      if (!dontPost) {
        fetchNui('inputData');
      }
    }, 200);
  };

  const onSubmit = form.handleSubmit((data) => {
    setVisible(false);
    const values: any[] = [];
    for (let i = 0; i < fields.rows.length; i++) {
      const row = fields.rows[i];

      if ((row.type === 'date' || row.type === 'date-range') && row.returnString) {
        if (!data.test[i]) continue;
        data.test[i].value = dayjs(data.test[i].value).format(row.format || 'DD/MM/YYYY');
      }
    }
    Object.values(data.test).forEach((obj: { value: any }) => values.push(obj.value));
    if (closeTimeout.current) {
      clearTimeout(closeTimeout.current);
    }
    closeTimeout.current = window.setTimeout(() => {
      form.reset();
      fieldForm.remove();
      closeTimeout.current = null;
      fetchNui('inputData', values);
    }, 200);
  });

  return (
    <>
      <Modal
        opened={visible}
        onClose={handleClose}
        centered
        closeOnEscape={fields.options?.allowCancel !== false}
        closeOnClickOutside={false}
        size={fields.options?.size || 480}
        withCloseButton={false}
        overlayOpacity={0.5}
        transition="fade"
        exitTransitionDuration={150}
        styles={{
          modal: { background: 'transparent', boxShadow: 'none', padding: 0 },
          body: { padding: 0 },
        }}
      >
        {/* Single wrapper card: label section (heading) + content section (form + actions) */}
        <Box className={classes.mainWrapper}>
          <Box className={classes.labelSection}>
            <Text className={classes.mainLabel}>
              <span>{fields.heading}</span>
              <span>:</span>
            </Text>
          </Box>
          <Box className={classes.contentSection}>
            <form onSubmit={onSubmit}>
              <Stack>
                {fieldForm.fields.map((item, index) => {
                  const row = fields.rows[index];
                  return (
                    <React.Fragment key={item.id}>
                      {row.type === 'input' && (
                        <InputField
                          register={form.register(`test.${index}.value`, { required: row.required })}
                          row={row}
                          index={index}
                        />
                      )}
                      {row.type === 'checkbox' && (
                        <CheckboxField
                          register={form.register(`test.${index}.value`, { required: row.required })}
                          row={row}
                          index={index}
                        />
                      )}
                      {(row.type === 'select' || row.type === 'multi-select') && (
                        <SelectField row={row} index={index} control={form.control} />
                      )}
                      {row.type === 'number' && <NumberField control={form.control} row={row} index={index} />}
                      {row.type === 'slider' && <SliderField control={form.control} row={row} index={index} />}
                      {row.type === 'color' && <ColorField control={form.control} row={row} index={index} />}
                      {row.type === 'time' && <TimeField control={form.control} row={row} index={index} />}
                      {row.type === 'date' || row.type === 'date-range' ? (
                        <DateField control={form.control} row={row} index={index} />
                      ) : null}
                      {row.type === 'textarea' && (
                        <TextareaField
                          register={form.register(`test.${index}.value`, { required: row.required })}
                          row={row}
                          index={index}
                        />
                      )}
                    </React.Fragment>
                  );
                })}
                <Grid gutter={10} mt={4}>
                  <Grid.Col span={6}>
                    <Button
                      fullWidth
                      uppercase
                      variant="filled"
                      color="red"
                      onClick={() => handleClose()}
                      disabled={fields.options?.allowCancel === false}
                    >
                      {locale.ui.cancel}
                    </Button>
                  </Grid.Col>
                  <Grid.Col span={6}>
                    <Button fullWidth uppercase variant="filled" type="submit">
                      {locale.ui.confirm}
                    </Button>
                  </Grid.Col>
                </Grid>
              </Stack>
            </form>
          </Box>
        </Box>
      </Modal>
    </>
  );
};

export default InputDialog;
